
import { ApiPromise, Keyring, WsProvider } from '@polkadot/api';
import { KeyringPair } from '@polkadot/keyring/types';
import { polketOptions } from '../src/service/types';


describe('polket-node module: `IdentityExtra` unit test', () => {

    let wsProvider: WsProvider;
    let api: ApiPromise;
    let keyring: Keyring;
    let user: KeyringPair;

    // Some mnemonic phrase
    const PHRASE = 'hello pencil unit ivory silk accuse army nation misery creek digital juice';

    beforeAll(async () => {
        // Construct
        wsProvider = new WsProvider('wss://testnet-node.polket.io');
        api = await ApiPromise.create({ provider: wsProvider, ...polketOptions });
        // Create a keyring instance
        keyring = new Keyring({ type: 'sr25519' });
        // Add an account, straight mnemonic
        user = keyring.addFromUri(PHRASE);

    });

    afterAll(async () => {
        // close connection
        await api.disconnect();
    });

    test('generate account unit test', async () => {
        const { nonce, data: balance } = await api.query.system.account(user.address);
        console.log(`user address: ${user.address}`);
        console.log(`user balance: ${balance.free}`);

    });

    test('producer set identity role unit test', async () => {

        const display = api.createType('Data', { 'Raw': 'hello' });
        const producer = api.createType('IdentityRole', 'Producer');
        const unsub = await api.tx.identityExtra.setIdentityRole({
            display: display,
        }, producer)
            .signAndSend(user, (result) => {
                console.log(`Current status is ${result.status}`);
                if (result.dispatchError) {
                    console.log(`dispatchError is ${result.dispatchError.toString()}`);
                }

                if (result.status.isInBlock) {
                    console.log(`Transaction included at blockHash ${result.status.asInBlock}`);
                } else if (result.status.isFinalized) {
                    console.log(`Transaction finalized at blockHash ${result.status.asFinalized}`);
                    unsub();
                }
            });

        await sleep(20000);
    });


});


const sleep = (ms) => new Promise(r => setTimeout(r, ms));

