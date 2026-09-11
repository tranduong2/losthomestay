// Integration checks using a temporary account; cleans up only its own records.
const {createRequire} = require('node:module');
const {resolve, join} = require('node:path');
const {randomUUID, randomBytes} = require('node:crypto');
const assert = require('node:assert/strict');
async function main() {
  const cli = createRequire(join(resolve(process.argv[2]), 'package.json'));
  await cli('./lib/requireAuth').requireAuth({...cli('./lib/auth').getGlobalDefaultAccount(), project: 'lost-31a48'});
  const {Client} = cli('./lib/apiv2');
  const admin = new Client({urlPrefix:'https://firestore.googleapis.com', apiVersion:'v1'});
  const root = 'projects/lost-31a48/databases/(default)/documents';
  const key = 'AIzaSyA2E1DRGjpns2FmzTKJnAfPtqO5YWItMBg';
  const created = [];
  let token;
  async function request(url, method, body, expected = 200) {
    const res = await fetch(url, {method, headers:{'Content-Type':'application/json', ...(token ? {Authorization:`Bearer ${token}`} : {})}, body:body ? JSON.stringify(body) : undefined});
    const data = await res.json();
    assert.equal(res.status, expected, `${method}: ${data.error?.message ?? res.status}`);
    return data;
  }
  const base = `https://firestore.googleapis.com/v1/${root}`;
  const str = value => ({stringValue:value});
  const num = value => ({integerValue:String(value)});
  const id = `check-${randomUUID()}`;
  try {
    const room = await request(`${base}/rooms/R001`, 'GET');
    await request(`${base}/users/example-customer`, 'GET', undefined, 403);
    const signup = await request(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${key}`, 'POST', {
      email:`${id}@example.com`, password:randomBytes(24).toString('base64url'), returnSecureToken:true,
    });
    token = signup.idToken;
    const uid = signup.localId;
    const profile = {name:str('Integration check'), email:str(signup.email), phone:str(''), role:str('customer')};
    await request(`${base}/users?documentId=${uid}`, 'POST', {fields:profile}); created.push(`${root}/users/${uid}`);
    await request(`${base}/users/${uid}?updateMask.fieldPaths=role`, 'PATCH', {fields:{role:str('admin')}}, 403);
    const start = new Date(); start.setUTCDate(start.getUTCDate()+7); start.setUTCHours(17,0,0,0);
    const end = new Date(start.getTime()+2*86400000);
    const price = Number(room.fields.pricePerNight.integerValue ?? room.fields.pricePerNight.doubleValue);
    const fields = {
      roomId:str('R001'), roomName:room.fields.name, userId:str(uid), userName:str('Integration check'),
      contactPhone:str(''), checkIn:{timestampValue:start.toISOString()}, checkOut:{timestampValue:end.toISOString()},
      guests:num(2), subtotal:num(price*2), discountPercent:num(0), total:num(price*2),
      discountCode:{nullValue:null}, status:str('pending'), paymentMethod:str('Thanh toán tại homestay'),
    };
    const name = `${root}/bookings/${id}`;
    function commit(data) {
      return {writes:[{update:{name, fields:data}, currentDocument:{exists:false}, updateTransforms:[{fieldPath:'createdAt', setToServerValue:'REQUEST_TIME'}]}]};
    }
    await request(`${base}:commit`, 'POST', commit({...fields, total:num(1)}), 403);
    await request(`${base}:commit`, 'POST', commit({...fields, userId:str('example-customer')}), 403);
    await request(`${base}:commit`, 'POST', commit({...fields, status:str('confirmed')}), 403);
    await request(`${base}:commit`, 'POST', commit(fields)); created.push(name);
    await request(`${base}/bookings/${id}`, 'GET');
    await request(`${base}/bookings/${id}?updateMask.fieldPaths=status`, 'PATCH', {fields:{status:str('cancelled')}});
    const contact = `${root}/contact_requests/${id}`;
    await request(`${base}:commit`, 'POST', {writes:[{
      update:{name:contact, fields:{userId:str(uid), name:str('Integration check'), email:str(signup.email), phone:str(''), message:str('Temporary connection test'), status:str('new')}},
      currentDocument:{exists:false}, updateTransforms:[{fieldPath:'createdAt',setToServerValue:'REQUEST_TIME'}],
    }]}); created.push(contact);
    await request(`${base}/contact_requests/${id}`, 'GET', undefined, 403);
    console.log('PASS: public rooms; private profiles; signup; profile save; blocked role escalation, price tampering, foreign ownership and self-confirmation; booking save/read/cancel; private contact submission.');
  } finally {
    if (created.length) await admin.post(`${root}:commit`, {writes:created.map(name=>({delete:name}))});
    if (token) await request(`https://identitytoolkit.googleapis.com/v1/accounts:delete?key=${key}`, 'POST', {idToken:token});
    console.log('Temporary test records and account cleaned up.');
  }
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
