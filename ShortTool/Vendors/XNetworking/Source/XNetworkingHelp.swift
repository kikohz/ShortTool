//
//  XNetworkingHelp.swift
//  ShortTool
//
//  Created by Bllgo on 2018/8/27.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import Foundation
func printLog<T>(message: T,
                 file: String = #file,
                 method: String = #function,
                 line: Int = #line)
{
    #if DEBUG
    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}
