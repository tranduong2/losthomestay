// Use the user's existing Firebase CLI session without exporting credentials.
const { createRequire } = require('node:module');
const { resolve, join } = require('node:path');
const { readFileSync } = require('node:fs');
const assert = require('node:assert/strict');

async function main() {
  const [cliDirectory, mode = 'inspect'] = process.argv.slice(2);
  assert(cliDirectory, 'Pass the installed firebase-tools directory.');
  assert(['inspect', 'seed', 'verify', 'create-user-example', 'create-booking-example', 'create-contact-example', 'finalize-schema'].includes(mode));
  const cli = createRequire(join(resolve(cliDirectory), 'package.json'));
  const account = cli('./lib/auth').getGlobalDefaultAccount();
  assert(account, 'Run firebase login first.');
  await cli('./lib/requireAuth').requireAuth({ ...account, project: 'lost-31a48' });
  const { Client } = cli('./lib/apiv2');
  const client = new Client({ urlPrefix: 'https://firestore.googleapis.com', apiVersion: 'v1' });
  const root = 'projects/lost-31a48/databases/(default)/documents';
  if (mode === 'finalize-schema') {
    const path = `${root}/contact_requests/example-contact`;
    const before = (await client.get(path)).body;
    if (!before.fields.userId) {
      assert.equal(before.fields.isDemo?.booleanValue, true);
      await client.post(`${root}:commit`, {writes: [{
        update: {name: path, fields: {userId: {stringValue: 'example-customer'}}},
        updateMask: {fieldPaths: ['userId']},
        currentDocument: {updateTime: before.updateTime},
      }]});
    }
    const schema = {
      rooms: ['name','description','pricePerNight','imageUrl','maxGuests','amenities','status','cleaningStatus','rating'],
      users: ['name','email','phone','role'],
      bookings: ['roomId','userId','userName','contactPhone','checkIn','checkOut','guests','subtotal','discountPercent','total','discountCode','status','paymentMethod','createdAt'],
      discounts: ['code','percent','expiry','active'],
      contact_requests: ['userId','name','email','phone','message','status','createdAt'],
    };
    for (const [collection, required] of Object.entries(schema)) {
      let count = 0, pageToken;
      do {
        const result = (await client.get(`${root}/${collection}`, {queryParams: {pageSize: 100, ...(pageToken ? {pageToken} : {})}})).body;
        for (const doc of result.documents || []) {
          for (const key of required) assert(key in doc.fields, `${collection}/${doc.name.split('/').pop()}: missing ${key}`);
          assert(!('password' in doc.fields), 'Plaintext password field found');
          count++;
        }
        pageToken = result.nextPageToken;
      } while (pageToken);
      assert(count > 0, `${collection} is empty`);
      console.log(`${collection}: ${count} records, approved fields verified`);
    }
    return;
  }
  if (mode === 'create-contact-example') {
    const name = `${root}/contact_requests/example-contact`;
    const fields = {
      userId: { stringValue: 'example-customer' },
      name: { stringValue: 'Khách liên hệ mẫu' },
      email: { stringValue: 'customer@example.com' },
      phone: { stringValue: '' },
      message: { stringValue: 'Nội dung mẫu cho form liên hệ; không phải yêu cầu của khách thật.' },
      status: { stringValue: 'closed' },
      isDemo: { booleanValue: true },
      createdAt: { timestampValue: new Date().toISOString() },
    };
    await client.post(`${root}:commit`, {
      writes: [{ update: { name, fields }, currentDocument: { exists: false } }],
    });
    const actual = (await client.get(name)).body.fields;
    for (const [key, value] of Object.entries(fields)) {
      if (value.timestampValue) assert.equal(Date.parse(actual[key].timestampValue), Date.parse(value.timestampValue));
      else assert.deepEqual(actual[key], value);
    }
    console.log('Created and verified contact_requests/example-contact (demo, closed).');
    return;
  }
  if (mode === 'create-booking-example') {
    const room = (await client.get(`${root}/rooms/R001`)).body;
    const user = (await client.get(`${root}/users/example-customer`)).body;
    const price = Number(room.fields.pricePerNight.integerValue ?? room.fields.pricePerNight.doubleValue);
    assert(Number.isFinite(price) && price > 0);
    const name = `${root}/bookings/example-booking`;
    const fields = {
      roomId: { stringValue: 'R001' },
      roomName: room.fields.name,
      userId: { stringValue: 'example-customer' },
      userName: user.fields.name,
      contactPhone: { stringValue: '' },
      checkIn: { timestampValue: '2026-09-15T07:00:00Z' },
      checkOut: { timestampValue: '2026-09-17T07:00:00Z' },
      guests: { integerValue: '2' },
      subtotal: { integerValue: String(price * 2) },
      discountPercent: { integerValue: '0' },
      total: { integerValue: String(price * 2) },
      discountCode: { nullValue: null },
      createdAt: { timestampValue: new Date().toISOString() },
      status: { stringValue: 'cancelled' },
      paymentMethod: { stringValue: 'Thanh toán tại homestay' },
      isDemo: { booleanValue: true },
      note: { stringValue: 'Lịch mẫu để xem cấu trúc; không giữ phòng, không phát sinh thanh toán.' },
    };
    await client.post(`${root}:commit`, {
      writes: [{ update: { name, fields }, currentDocument: { exists: false } }],
    });
    const saved = (await client.get(name)).body.fields;
    // Firestore can normalize fractional seconds in timestamps.
    for (const [key, value] of Object.entries(fields)) {
      if (value.timestampValue) assert.equal(Date.parse(saved[key].timestampValue), Date.parse(value.timestampValue));
      else assert.deepEqual(saved[key], value);
    }
    console.log('Created and verified bookings/example-booking. Demo only, cancelled; no room reservation or payment.');
    return;
  }
  if (mode === 'create-user-example') {
    // Schema example only: real profiles must use their Firebase Auth UID.
    const name = `${root}/users/example-customer`;
    const fields = {
      name: { stringValue: 'Khách hàng mẫu (chưa có tài khoản đăng nhập)' },
      email: { stringValue: 'customer@example.com' },
      phone: { stringValue: '' },
      role: { stringValue: 'customer' },
    };
    await client.post(`${root}:commit`, {
      writes: [{ update: { name, fields }, currentDocument: { exists: false } }],
    });
    const result = await client.get(name);
    assert.deepEqual(result.body.fields, fields);
    console.log('Created and verified users/example-customer. Profile example only; no Auth account or password created.');
    return;
  }
  const data = JSON.parse(readFileSync(join(__dirname, 'seed.json'), 'utf8'));
  function encode(value) {
    if (value === null) return { nullValue: null };
    if (typeof value === 'string') return { stringValue: value };
    if (typeof value === 'boolean') return { booleanValue: value };
    if (typeof value === 'number') return Number.isInteger(value) ? { integerValue: String(value) } : { doubleValue: value };
    if (Array.isArray(value)) return { arrayValue: { values: value.map(encode) } };
    throw new Error('Unsupported seed value');
  }
  const writes = Object.entries(data).flatMap(([collection, documents]) =>
    Object.entries(documents).map(([id, fields]) => ({
      update: { name: `${root}/${collection}/${id}`, fields: Object.fromEntries(
        Object.entries(fields).map(([key, value]) => [key, key === 'expiry'
          ? { timestampValue: new Date(value).toISOString() } : encode(value)])
      ) }, currentDocument: { exists: false }
    })));
  if (mode === 'seed') {
    const result = await client.post(`${root}:commit`, { writes });
    console.log(`Created ${result.body.writeResults.length} documents in lost-31a48.`);
  } else {
    for (const collection of ['rooms', 'discounts', 'users', 'bookings', 'contact_requests']) {
      const result = await client.get(`${root}/${collection}`, { queryParams: { pageSize: 100 } });
      const docs = result.body.documents || [];
      console.log(`${collection}: ${docs.length}${result.body.nextPageToken ? '+' : ''} documents`);
      if (mode === 'verify' && data[collection]) {
        for (const [id] of Object.entries(data[collection])) {
          const actual = docs.find(d => d.name === `${root}/${collection}/${id}`);
          assert(actual, `Missing ${collection}/${id}`);
          const expected = writes.find(w => w.update.name === actual.name).update.fields;
          assert.deepEqual(actual.fields, expected, `Data mismatch: ${collection}/${id}`);
        }
      }
    }
    if (mode === 'verify') console.log('All 15 catalog documents match the local seed, including Timestamp values.');
  }
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
