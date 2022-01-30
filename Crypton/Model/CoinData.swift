//
//  CoinData.swift
//  Crypton
//
//  Created by Alexandr on 30.11.2021.
//

// Example:

//"time": "2021-11-30T20:27:22.0000000Z",
//"asset_id_base": "DOGE",
//"asset_id_quote": "RUB",
//"rate": 16.049229598942310686058267348,

import UIKit

struct CoinData: Codable {
    
    var asset_id_base: String
    var asset_id_quote: String
    var rate: Double
    
}
