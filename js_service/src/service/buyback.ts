import { ApiPromise } from "@polkadot/api";

/**
 * query all buyback plans
 * @param api ApiPromise
 */
async function getBuybackPlans(api: ApiPromise) {
    const plans = await api.query.buyback.buybackPlans.entries<any>();
    return plans.map(([{ args: [id] }, e]) => {
        var obj = e.toJSON();
        obj['id'] = (id as any).toNumber();
        return obj;
    });
}

export default {
    getBuybackPlans,
}