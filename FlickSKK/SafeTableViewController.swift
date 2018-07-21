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

    init(style: UITableView.Style) {
        super.init(nibName: nil, bundle: nil)

        view = UITableView(frame: CGRect.zero, style: style)
        tableView.delegate = self
        tableView.dataSource = self
        viewDidLoad()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        // do nothing
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: animated)
        }
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.flashScrollIndicators()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("tableView(tableView:cellForRowAtIndexPath:) has not been implemented")
    }
}
