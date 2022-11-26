import { ApiPromise } from "@polkadot/api";

/**
 * get VFE detail of brandId By address 
 */
async function getVFEDetailsByAddress(api: ApiPromise, address: string, brandId: number) {
    const items = await api.query.vfeUniques.account.keys<[any, any, any]>(address, brandId);
    const ids = items.map(({ args: [, brandId, itemId] }) => [brandId, itemId]);
    const details = await api.query.vfe.vfeDetails.multi(ids);
    return details.map((e)=> e.toJSON());
}

export default {
    getVFEDetailsByAddress,
};