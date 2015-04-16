//
//  SafeTableViewController.swift
//  FlickSKK
//
//  Created by BAN Jun on 2015/04/13.
//  Copyright (c) 2015年 BAN Jun. All rights reserved.
//

// NOTE: workaround for fatal error: use of unimplemented initializer 'init(nibName:bundle:)'
// see https://github.com/banjun/SwiftUnsafeTableViewController
// remove after everything is purified

import UIKit

class SafeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView { return view as! UITableView }

    init(style: UITableViewStyle) {
        super.init(nibName: nil, bundle: nil)

        view = UITableView(frame: CGRectZero, style: style)
        tableView.delegate = self
        tableView.dataSource = self
        viewDidLoad()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        // do nothing
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let selected = tableView.indexPathForSelectedRow() {
            tableView.deselectRowAtIndexPath(selected, animated: animated)
        }
        tableView.reloadData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        tableView.flashScrollIndicators()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        fatalError("tableView(tableView:cellForRowAtIndexPath:) has not been implemented")
    }
}
