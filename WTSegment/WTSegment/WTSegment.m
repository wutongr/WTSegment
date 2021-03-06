//
// WTSegment.h
//
// Copyright (c) 2015 wutongr (http://www.wutongr.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "WTSegment.h"
#import "WTSegmentProtocol.h"

#define ITEM_MAX          6
#define FRAME_H           (self.frame.size.height)
#define FRAME_W           (self.frame.size.width)

@interface WTScrollView : UIScrollView

@end

@implementation WTScrollView

- (void)setContentOffset:(CGPoint)contentOffset{
    //Fix navigationBarHidden Bug
    if(!CGPointEqualToPoint(self.contentOffset, CGPointMake(self.contentOffset.x, 0))){
        contentOffset = CGPointMake(self.contentOffset.x, 0);
    }
    [super setContentOffset:contentOffset];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self nextResponder] touchesBegan:touches withEvent:event];
    //    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self nextResponder] touchesMoved:touches withEvent:event];
    //    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self nextResponder] touchesEnded:touches withEvent:event];
    //    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self nextResponder]touchesCancelled:touches withEvent:event];
    //    [super touchesCancelled:touches withEvent:event];
}

@end

@interface WTSegment ()

@property (nonatomic, strong) WTScrollView *floorView;
@property (nonatomic, strong) UIView *cursorView;
@property (nonatomic, strong) UIView<WTSegmentProtocol> *crtItem;
@property (nonatomic, strong) UIView<WTSegmentProtocol> *selItem;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, assign) CGFloat itemWidth;

@end

@implementation WTSegment

#pragma mark - 初始化 

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        _style = WTSegmentStylePlain;
        
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        _style = WTSegmentStylePlain;
        
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(WTSegmentStyle)style{
    if(self = [super initWithFrame:frame]){
        _style = style;
        
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setup];
}

- (void)commonInit{
    _itemsMax = ITEM_MAX;
    _cornerRadius = 10.0f;
    _cursorHeight = 3;
    _cursorSpace = 0;
    _cursorStyle = WTSegmentCursorStyleBottom;
}

- (WTScrollView *)floorView{
    if(!_floorView){
        _floorView = [[WTScrollView alloc]initWithFrame:CGRectMake(0, 0, FRAME_W, FRAME_H)];
        [_floorView setBounces:NO];
        [_floorView setShowsHorizontalScrollIndicator:NO];
        [_floorView setShowsVerticalScrollIndicator:NO];
        [self addSubview:_floorView];
    }
    return _floorView;
}

- (UIView *)cursorView{
    if(!_cursorView){
        _cursorView = [[UIView alloc]initWithFrame:CGRectZero];
        [self.floorView addSubview:_cursorView];
    }
    return _cursorView;
}

- (NSMutableArray *)items{
    if(!_items){
        _items = [[NSMutableArray alloc]init];
    }
    return _items;
}

#pragma mark - 构造控件
- (void)setup{
    _selectedIndex = 0;
    _rows = [_dataSource numberOfRowsInWTSegment:self];
    _itemWidth = _rows <= _itemsMax ? FRAME_W / _rows : FRAME_W / _itemsMax;
    
    [self.floorView setFrame:CGRectMake(0, 0, FRAME_W, FRAME_H)];
    [self.cursorView setBackgroundColor:_cursorColor];

    [self updateCursorOffset:0];
    
    [self.items enumerateObjectsUsingBlock:^(UIView<WTSegmentProtocol> *obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    [self.items removeAllObjects];
    
    for(int i = 0; i < _rows; i++){
        UIView<WTSegmentProtocol> *item = [_dataSource WTSegment:self itemAtRow:i];
        [self.items addObject:item];
    }
    
    switch (_style) {
        case WTSegmentStyleGroup:
            break;
        case WTSegmentStylePlain:
            break;
    }
    
    [self.items enumerateObjectsUsingBlock:^(UIView<WTSegmentProtocol> *obj, NSUInteger idx, BOOL *stop) {
        if(idx == 0){
            [obj setSelected:YES];
            self.crtItem = obj;
            self.selItem = obj;
        }else{
            [obj setSelected:NO];
        }
        switch (_cursorStyle) {
            case WTSegmentCursorStyleBottom:
                [obj setFrame:CGRectMake(_itemWidth * idx, 0, _itemWidth, FRAME_H - _cursorHeight)];
                break;
            case WTSegmentCursorStyleMiddle:
                [obj setFrame:CGRectMake(_itemWidth * idx, _cursorHeight, _itemWidth, FRAME_H - _cursorHeight * 2)];
                break;
            case WTSegmentCursorStyleTop:
                [obj setFrame:CGRectMake(_itemWidth * idx, _cursorHeight, _itemWidth, FRAME_H - _cursorHeight)];
                break;
        }
        
        [self.floorView addSubview:obj];
    }];
    
    if(_rows > _itemsMax){
        [self.floorView setContentSize:CGSizeMake(FRAME_W + (_rows - _itemsMax) * _itemWidth, FRAME_H)];
    }else{
        [self.floorView setContentSize:CGSizeZero];
    }
}

#pragma mark - 刷新
- (void)reloadSegment{
    [self setup];
}

#pragma mark - 滑动事件
- (void)scrollToRow:(NSInteger)row animation:(BOOL)animation{
    self.selItem = [self itemAtRow:row];
    [self.selItem setSelected:YES];
    if(self.crtItem != self.selItem){
        [self.crtItem setSelected:NO];
        self.crtItem = self.selItem;
        _selectedIndex = [self.items indexOfObject:self.crtItem];
    }
}

- (void)scrollToOffset:(CGFloat)offset{
    CGFloat itemOffset = offset / (_rows <= _itemsMax ? _rows :_itemsMax);
    [self updateCursorOffset:itemOffset];
    [self updateItemOffset:itemOffset];
    [self updateScrollViewOffset:itemOffset];
}

#pragma mark - 触摸事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint location = [[touches anyObject] locationInView:self.floorView];
    [self.items enumerateObjectsUsingBlock:^(UIView<WTSegmentProtocol> *obj, NSUInteger idx, BOOL *stop) {
        if(CGRectContainsPoint(obj.frame, location))
        {
            [obj setSelected:YES];
            self.selItem = obj;
            *stop = YES;
        }
    }];
    //传递到下级响应
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint location = [[touches anyObject] locationInView:self.floorView];
    
    [self.items enumerateObjectsUsingBlock:^(UIView<WTSegmentProtocol> *obj, NSUInteger idx, BOOL *stop) {
        if(CGRectContainsPoint(obj.frame, location))
        {
            [obj setSelected:YES];
            if(self.selItem != obj && self.selItem != self.crtItem){
                [self.selItem setSelected:NO];
            }
            self.selItem = obj;
            *stop = YES;
        }
     }];
    
    [[self nextResponder] touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(_delegate && [_delegate respondsToSelector:@selector(WTSegment:shouldSelectedAtRow:)]){
        if([_delegate WTSegment:self shouldSelectedAtRow:[self.items indexOfObject:self.selItem]] == NO){
            [self touchesCancelled:touches withEvent:event];
            return;
        }
    }
    
    if(self.crtItem != self.selItem){
        [self.crtItem setSelected:NO];
        self.crtItem = self.selItem;
        _selectedIndex = [self.items indexOfObject:self.crtItem];
    }
    
    if(_delegate && [_delegate respondsToSelector:@selector(WTSegment:didSelectedAtRow:)]){
        [_delegate WTSegment:self didSelectedAtRow:_selectedIndex];
    }
    
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.crtItem != self.selItem)
        [self.selItem setSelected:NO];
    
    [[self nextResponder] touchesCancelled:touches withEvent:event];
}

#pragma mark - Utils
- (void)updateCursorOffset:(CGFloat)offset{
    switch (_cursorStyle) {
        case WTSegmentCursorStyleBottom:
            [self.cursorView setFrame:CGRectMake(offset + _cursorSpace, FRAME_H - _cursorHeight, _itemWidth - _cursorSpace * 2, _cursorHeight)];
            break;
        case WTSegmentCursorStyleMiddle:
            self.cursorView.layer.cornerRadius = _cornerRadius;
            [self.cursorView setFrame:CGRectMake(offset + _cursorSpace, 6, _itemWidth - _cursorSpace * 2, FRAME_H - 6 * 2)];
            break;
        case WTSegmentCursorStyleTop:
            [self.cursorView setFrame:CGRectMake(offset + _cursorSpace, 0, _itemWidth - _cursorSpace * 2, _cursorHeight)];
            break;
    }
}

- (void)updateScrollViewOffset:(CGFloat)offset{
    if(_rows <= _itemsMax) return;

    if(offset > _itemWidth * (_itemsMax - 3) && offset < _itemWidth * (_rows - 3)){
        [self.floorView setContentOffset:CGPointMake(_itemWidth * (3 - _itemsMax) + offset, self.floorView.contentOffset.y)];
    }else if (offset <= _itemWidth * (_itemsMax - 3)){
        [self.floorView setContentOffset:CGPointMake(0, self.floorView.contentOffset.y)];
    }else if (offset >= _itemWidth * (_rows - 3)){
        [self.floorView setContentOffset:CGPointMake(_itemWidth * (_rows - _itemsMax), self.floorView.contentOffset.y)];
    }
}

- (void)updateItemOffset:(CGFloat)offset{    
    UIView<WTSegmentProtocol> *item;
    item = [self itemAtRow:floorf(offset / _itemWidth)];
    [item setProgress:1 - offset / _itemWidth + floorf(offset / _itemWidth)];
    
    item = [self itemAtRow:floorf(offset / _itemWidth) + 1];
    [item setProgress:offset / _itemWidth - floorf(offset / _itemWidth)];
}

- (UIView<WTSegmentProtocol> *)itemAtRow:(NSInteger)row{
    if(row < 0 || row >= self.items.count) return nil;
    return [self.items objectAtIndex:row];
}

@end
