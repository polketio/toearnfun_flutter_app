
import { ApiPromise } from "@polkadot/api";

/**
 * query all VFE orders
 * @param api ApiPromise
 */
async function getOrdersAll(api: ApiPromise) {
    const orders = await api.query.vfeOrder.orders.entries<any>();
    var result = orders.map(([{ args: [owner, id] }, e]) => {
        var obj = e.toJSON();
        obj['id'] = (id as any).toNumber();
        obj['owner'] = owner;
        return obj;
    });

    for (var obj of result) {
        const items = obj['items'];
        const ids = items.map((e) => [e['collectionId'], e['itemId']]);
        const details = await api.query.vfe.vfeDetails.multi(ids);
        obj['details'] = details.map((e) => {
            var d = e.toJSON();
            d['owner'] = obj['owner'];
            return d;
        });
    }
    return result;
}

export default {
    getOrdersAll,
}