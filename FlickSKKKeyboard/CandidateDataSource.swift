//
//  File.swift
//  SKK-for-iOS
//
//  Created by mzp on 2014/09/28.
//  Copyright (c) 2014年 codefirst. All rights reserved.
//

import UIKit

class CandidateDataSource: NSObject, UITableViewDataSource {
    var candidates : [String] = []

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        let candidate = (index < candidates.count) ? candidates[index] : "";
        let cell = tableView.dequeueReusableCellWithIdentifier(candidate) as UITableViewCell?

        if(cell != nil) {
            cell?.textLabel?.text = candidate
            return cell!
        } else {
            let c = UITableViewCell(style: .Default, reuseIdentifier: candidate)
            c.textLabel?.text = candidate
            return c
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return candidates.count
    }

    func update(xs : [String]){
        self.candidates = xs
    }
}
