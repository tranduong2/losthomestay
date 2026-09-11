const {createRequire} = require('node:module');
const {resolve, join} = require('node:path');
async function main() {
  const cli = createRequire(join(resolve(process.argv[2]), 'package.json'));
  await cli('./lib/requireAuth').requireAuth({...cli('./lib/auth').getGlobalDefaultAccount(), project: 'lost-31a48'});
  const {Client} = cli('./lib/apiv2');
  const client = new Client({urlPrefix: 'https://identitytoolkit.googleapis.com', auth: true});
  const path = '/admin/v2/projects/lost-31a48/config';
  const options = {headers: {'x-goog-user-project': 'lost-31a48'}};
  const before = (await client.get(path, options)).body;
  console.log('Email/password enabled:', before.signIn?.email?.enabled === true);
  if (process.argv.includes('--enable') && before.signIn?.email?.enabled !== true) {
    await client.patch(path, {signIn: {email: {enabled: true, passwordRequired: true}}},
      {...options, queryParams: {updateMask: 'signIn.email.enabled,signIn.email.passwordRequired'}});
    console.log('Enabled email/password sign-in.');
  }
}
main().catch(e => {console.error(e.message); process.exitCode = 1;});
