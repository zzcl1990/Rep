//
//  WeakProxy.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/4/4.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation

class WeakProxy<Input, Output> {
    init() { }
    
    private var closure: ((Input) -> Output?)?
    func proxy<T: AnyObject>(on target: T, closure: ((T, Input) -> Output)?) {
        self.closure = { [weak target] input in
            guard let target = target else { return nil }
            return closure?(target, input)
        }
    }
    
    func invoke(_ input: Input) -> Output? {
        return closure?(input)
    }
}
