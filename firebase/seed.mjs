import { readFile } from 'node:fs/promises';
import assert from 'node:assert/strict';

const data = JSON.parse(await readFile(new URL('./seed.json', import.meta.url), 'utf8'));
assert.deepEqual(Object.keys(data).sort(), ['discounts', 'rooms']);
for (const room of Object.values(data.rooms)) {
  assert.equal(typeof room.name, 'string');
  assert(room.pricePerNight > 0 && Number.isInteger(room.maxGuests) && room.maxGuests > 0);
  assert(Array.isArray(room.amenities));
  assert(['available', 'occupied', 'maintenance'].includes(room.status));
  assert(['clean', 'dirty', 'cleaning'].includes(room.cleaningStatus));
}
for (const discount of Object.values(data.discounts)) {
  assert(discount.percent >= 0 && discount.percent <= 100);
  assert(Number.isFinite(Date.parse(discount.expiry)));
}
if (process.argv.includes('--dry-run')) {
  console.log(`Valid: ${Object.keys(data.rooms).length} rooms, ${Object.keys(data.discounts).length} discounts. No database writes.`);
} else {
  const projectId = process.argv[2];
  if (!projectId || projectId.startsWith('--')) throw new Error('Usage: npm run seed -- YOUR_PROJECT_ID');
  const { initializeApp, applicationDefault } = await import('firebase-admin/app');
  const { getFirestore, Timestamp } = await import('firebase-admin/firestore');
  initializeApp({ projectId, credential: applicationDefault() });
  const db = getFirestore();
  const batch = db.batch();
  for (const [collection, documents] of Object.entries(data)) {
    for (const [id, fields] of Object.entries(documents)) {
      const value = { ...fields };
      if (collection === 'discounts') value.expiry = Timestamp.fromDate(new Date(value.expiry));
      // Atomic create prevents overwriting any existing catalog records.
      batch.create(db.collection(collection).doc(id), value);
    }
  }
  await batch.commit();
  console.log(`Catalog created in ${projectId}.`);
}
