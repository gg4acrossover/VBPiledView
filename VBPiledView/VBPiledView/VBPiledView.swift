//
//  VBPiledView.swift
//  VBPiledView
//
//  Created by Viktor Braun (v-braun@live.de) on 02.07.16.
//  Copyright © 2016 dev-things. All rights reserved.
//


public protocol VBPiledViewDataSource{
    func piledView(numberOfItemsForPiledView: VBPiledView) -> Int
    func piledView(viewForPiledView: VBPiledView, itemAtIndex index: Int) -> UIView
}

public class VBPiledView: UIView, UIScrollViewDelegate {
    
    private let _scrollview = UIScrollView()
    public var dataSource : VBPiledViewDataSource?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initInternal();
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initInternal();
    }
    
    override public func layoutSubviews() {
        _scrollview.frame = self.bounds
        
        self.layoutContent()
        
        super.layoutSubviews()
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        layoutContent()
    }
    
    private func initInternal(){
        _scrollview.showsVerticalScrollIndicator = true
        _scrollview.showsHorizontalScrollIndicator = false
        _scrollview.scrollEnabled = true
        _scrollview.delegate = self
        
        self.addSubview(_scrollview)
    }
    
    private func layoutContent(){
        guard let data = dataSource else {return}
        
        let currentScrollPoint = CGPoint(x:0, y: _scrollview.contentOffset.y)
        let contentMinHeight = CGFloat(80)
        let contentMaxHeight = CGFloat((_scrollview.bounds.height / 4) * 3)
        
        var lastElementH = CGFloat(0)
        var lastElementY = currentScrollPoint.y
        
        let subViewNumber = data.piledView(self)
        _scrollview.contentSize = CGSize(width: self.bounds.width, height: _scrollview.bounds.height * CGFloat(subViewNumber))
        for index in 0..<subViewNumber {
            let v = data.piledView(self, itemAtIndex: index)
            if !v.isDescendantOfView(_scrollview){
                _scrollview.addSubview(v)
            }
            
            let y = lastElementY + lastElementH
            let currentViewUntransformedLocation = CGPoint(x: 0, y: (CGFloat(index) * _scrollview.bounds.height) + _scrollview.bounds.height)
            let prevViewUntransformedLocation = CGPoint(x: 0, y: currentViewUntransformedLocation.y - _scrollview.bounds.height)
            let slidingWindow = CGRect(origin: currentScrollPoint, size: _scrollview.bounds.size)
            
            var h = contentMinHeight
            if index == subViewNumber-1 {
                h = _scrollview.bounds.size.height
                if(currentScrollPoint.y > CGFloat(index) * _scrollview.bounds.size.height){
                    h = h + (currentScrollPoint.y - CGFloat(index) * _scrollview.bounds.size.height)
                }
            }
            else if CGRectContainsPoint(slidingWindow, currentViewUntransformedLocation){
                let relativeScrollPos = currentScrollPoint.y - (CGFloat(index) * _scrollview.bounds.size.height)
                let scaleFactor = (relativeScrollPos * 100) / _scrollview.bounds.size.height
                let diff = (scaleFactor * contentMaxHeight) / 100
                h = contentMaxHeight - diff
            }
            else if CGRectContainsPoint(slidingWindow, prevViewUntransformedLocation){
                h = contentMaxHeight - lastElementH
                if currentScrollPoint.y < 0 {
                    h = h + abs(currentScrollPoint.y)
                }
                else if(h < contentMinHeight){
                    h = contentMinHeight
                }
            }
            else if slidingWindow.origin.y > currentViewUntransformedLocation.y {
                h = 0
            }
            
            v.frame = CGRect(origin: CGPoint(x: 0, y: y), size: CGSize(width: _scrollview.bounds.width, height: h))
            
            lastElementH = v.frame.size.height
            lastElementY = v.frame.origin.y
        }
    }
    
}

