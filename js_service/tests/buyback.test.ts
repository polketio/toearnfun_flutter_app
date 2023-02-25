import { ApiPromise, Keyring, WsProvider } from '@polkadot/api';
import { KeyringPair } from '@polkadot/keyring/types';
import buyback from "../src/service/buyback";
import { polketOptions } from '../src/service/types';


describe('polket-node module: `buyback` unit test', () => {

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

    test('query VFE brands unit test', async () => {
        const plans = await buyback.getBuybackPlans(api);

        plans.forEach((plan) => {
            console.log(`plan: ${JSON.stringify(plan)}`);
        });
    });
});



