import { ApiPromise } from "@polkadot/api";

/**
 * get VFE detail of brandId By address 
 */
async function getVFEDetailsByAddress(api: ApiPromise, address: string, brandId: number) {
    const items = await api.query.vfeUniques.account.keys<[any, any, any]>(address, brandId);
    const ids = items.map(({ args: [, brandId, itemId] }) => [brandId, itemId]);
    const details = await api.query.vfe.vfeDetails.multi(ids);
    // return details.map((e) => e.toJSON());
    return details.map((e) => {
        var obj = e.toJSON();
        obj['owner'] = address;
        return obj;
    });
}

/**
 * query all VFE brands
 * @param api ApiPromise
 * @returns VFEBrand
 */
async function getVFEBrandsAll(api: ApiPromise) {
    const brands = await api.query.vfe.vfeBrands.entries<any>();
    return brands.map(([_, d]) => d.toJSON());
}

/**
 * query all producers
 * @param api ApiPromise
 * @returns Producer
 */
async function getProducerAll(api: ApiPromise) {
    const producers = await api.query.vfe.producers.entries<any>();
    return producers.map(([_, d]) => d.toJSON());
}

/**
 * Calculate VFE charging costs
 * @param api ApiPromise
 * @param brandId
 * @param item
 * @param chargeNum
 * @returns
 */
async function getChargingCosts(api: ApiPromise, brandId: number, item: number, chargeNum: number) {
    const costs = await (api.rpc as any).vfe.getChargingCosts(brandId, item, chargeNum);
    return costs;
}

/**
 * Calculate VFE level up costs
 * @param api ApiPromise
 * @param who
 * @param brandId
 * @param item
 * @returns
 */
async function getLevelUpCosts(api: ApiPromise, who: string, brandId: number, item: number) {
    const costs = await (api.rpc as any).vfe.getLevelUpCosts(who, brandId, item);
    return costs;
}

/**
 * query incentive token
 * @param api
 * @returns asset metadata
 */
async function getIncentiveToken(api: ApiPromise) {
    const incentiveAssetId: any = await api.query.vfe.incentiveToken();
    if (incentiveAssetId.isNone) {
        return null;
    }
    const data = await api.query.assets.metadata<any>(incentiveAssetId.unwrap());
    var obj = data.toHuman();
    obj['id'] = incentiveAssetId.unwrap().toNumber();
    return obj;
} 

export default {
    getVFEDetailsByAddress,
    getVFEBrandsAll,
    getProducerAll,
    getChargingCosts,
    getLevelUpCosts,
    getIncentiveToken,
};