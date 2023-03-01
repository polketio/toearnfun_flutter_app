import { ApiOptions } from '@polkadot/api/types';

export const polketOptions: ApiOptions = {
    types: {
        IdentityRole: {
            _enum: ['None', 'Brand', 'Producer', 'Exchange', 'Audit']
        },
    },
    rpc: {
        currencies: {
            totalIssuance: {
                description: 'Get total issuance of asset by id',
                params: [
                    {
                        name: 'asset',
                        type: 'u64'
                    },
                ],
                type: 'Balance'
            },
            minimumBalance: {
                description: 'Get minimum balance of asset by id',
                params: [
                    {
                        name: 'asset',
                        type: 'u64'
                    },
                ],
                type: 'Balance'
            },
            balance: {
                description: 'Get account balance of asset',
                params: [
                    {
                        name: 'asset',
                        type: 'u64'
                    },
                    {
                        name: 'who',
                        type: 'AccountId'
                    },
                ],
                type: 'Balance'
            },
            reducibleBalance: {
                description: 'Get account reducible balance of asset',
                params: [
                    {
                        name: 'asset',
                        type: 'u64'
                    },
                    {
                        name: 'who',
                        type: 'AccountId'
                    },
                    {
                        name: 'keepAlive',
                        type: 'bool'
                    },
                ],
                type: 'Balance'
            },
        },
        vfe: {
            getVFEDetailsByAddress: {
                description: 'Get VFE details by address',
                params: [
                    {
                        name: 'account',
                        type: 'AccountId'
                    },
                    {
                        name: 'brandId',
                        type: 'u64',
                    },
                ],
                type: 'VFEDetail'
            },
            getChargingCosts: {
                description: 'Calculate VFE charging costs',
                params: [
                    {
                        name: 'brandId',
                        type: 'u64'
                    },
                    {
                        name: 'item',
                        type: 'u64',
                    },
                    {
                        name: 'chargeNum',
                        type: 'u64',
                    }
                ],
                type: 'Balance'
            },
            getLevelUpCosts: {
                description: 'Calculate VFE level up costs',
                params: [
                    {
                        name: 'who',
                        type: 'AccountId'
                    },
                    {
                        name: 'brandId',
                        type: 'u64'
                    },
                    {
                        name: 'item',
                        type: 'u64',
                    }
                ],
                type: 'Balance'
            }
        }
    }
};