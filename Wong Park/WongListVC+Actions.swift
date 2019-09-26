//
//  WongListVC+Actions.swift
//  Wong Park
//
//  Created by Daniel Prastiwa on 24/07/19.
//  Copyright © 2019 Kipacraft. All rights reserved.
//

import UIKit

extension WongListVC {
    
    
    @objc func handleAddButton() {
        present(alertController(actionType: "add"), animated: true, completion: nil)
    }
    
    
}
