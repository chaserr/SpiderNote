//
//  SearchArticleCell.swift
//  Spider
//
//  Created by 童星 on 16/8/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

enum ClickViewType:Int {
    case title = 0
    case text = 1
    case pic = 2
    case video = 3
}
class SearchArticleCell: UITableViewCell {
    
    typealias TapAction = (_ type:ClickViewType, _ textSec: SectionObject?, _ picSec: PicSectionObject?, _ videoSec: SectionObject?) -> Void
    var tapAction:TapAction!
    
    /** cell */
    var sectionHeader: UIView!
    var titleView: UIView!
    var articleTitleLabel: UILabel!
    var updateTime: UILabel!
    var rightArrow: UIImageView!
    var textSectionView: TextSectionView!
    var videoSectionView: VideoSectionView!
    var picSectionView: PicSectionView!
    var progressLayer: CALayer!
    var searchKey:String!

    
    var articleModel:ArticleModel? {

        didSet{
        
            for item in contentView.subviews {
                if item is TextSectionView || item is PicSectionView || item is VideoSectionView {
                    item.removeFromSuperview()
                }
            }
            
            var titleViewH: CGFloat = 60
            if self.articleModel?.updateTime == nil {
                titleViewH = 40
            }
            
            titleView.frame = CGRect(x: 0, y: sectionHeader.frame.maxY, width: kScreenWidth, height: titleViewH)
            
            
            articleTitleLabel.attributedText = articleModel?.title!.colorSubString(searchKey, color: UIColor.red)
            let articleUpdateTime = DateUtil.string(withDateFormat: articleModel!.updateTime, sFormat: kDU_YYYYMMddhhmmss, dFormat: kDU_MMdd)
            updateTime.text = articleUpdateTime
            if articleModel?.textSectionArr.count != 0 {
                for (index,item) in articleModel!.textSectionArr.enumerated() {
                    let headString = item.text
                        let textSectionView = TextSectionView(frame: CGRect(x: 0,y: self.titleView.frame.maxY + 90 * CGFloat(index), width: kScreenWidth, height: 90))
                        contentView.addSubview(textSectionView)
                        textSectionView.tapTextView { (type) in
                            self.tapAction(type, item, nil, nil)
                        }
                    
                    if headString?.height(kScreenWidth - 30 - 20, font: SYSTEMFONT(16), lineBreakMode: NSLineBreakMode.byWordWrapping) > 64 {
                        let subSRange:Range = (headString?.range(of: searchKey))!
                        let subIndex:Int    = (headString?.characters.distance(from: (headString?.startIndex)!, to: subSRange.lowerBound))!
                        let oneTosearchSub  = headString?.substring(to: headString!.characters.index(headString!.startIndex, offsetBy: subIndex))
                        if oneTosearchSub?.height(kScreenWidth - 30 - 20, font: SYSTEMFONT(16), lineBreakMode: NSLineBreakMode.byWordWrapping) > 64 {
                            // 1. 前10个字符串
                            let preTenString: String                   = (headString?.substring(to: headString!.characters.index(headString!.startIndex, offsetBy: 10)))!
                            // 2. 靠近搜索关键字的字符串
//                            let range                                  = ClosedRange(subSRange.startIndex.advancedBy(-10)...subSRange.startIndex.advancedBy(10))
//                            let searchNearByS: String                  = (headString!.substring(with: range))
                            let lastStr: String                        = (headString?.substring(from: headString!.characters.index(headString!.endIndex, offsetBy: -5)))!
//                            let resultString                           = "\(preTenString)...\(searchNearByS)...\(lastStr)"
                            let resultString                           = "\(preTenString)...\(lastStr)"

                            textSectionView.contentText.attributedText = resultString.colorSubString(searchKey, color: UIColor.red)
                            continue
                        }
                        
                        
                    }
                        textSectionView.contentText.attributedText = headString!.colorSubString(searchKey, color: UIColor.red)
                    
                    if index == (articleModel?.textSectionArr.count)! - 1 {
                        self.textSectionView = textSectionView
                    }
                }

            }
            else{
            
                textSectionView = TextSectionView(frame: CGRect(x: 0,y: self.titleView.frame.maxY, width: kScreenWidth, height: 0))
            }
            
            if articleModel?.picSectionArr.count != 0 {

                for (index, item) in articleModel!.picSectionArr.enumerated() {
                    let picSectionView = PicSectionView(frame: CGRect(x: 0, y: self.textSectionView.frame.maxY + 250 * CGFloat(index), width: kScreenWidth, height: 250))
                    contentView.addSubview(picSectionView)
                    let headString = item.tags.filter(NSPredicate(format: "type == 0 AND content CONTAINS[c] %@", searchKey)).toArray().first?.content
                    picSectionView.tapPicView({ (type) in
                        self.tapAction(type, nil, item, nil)
                    })
                    
                    picSectionView.imageTagView.attributedText = headString!.colorSubString(searchKey, color: UIColor.red)
                    picSectionView.imageView.spider_setImageWith(PicInfo(object: item))
                    
                    if index == articleModel!.picSectionArr.count - 1 {
                        self.picSectionView = picSectionView
                    }
                }
            }
            else{
            
                picSectionView = PicSectionView(frame: CGRect(x: 0,y: self.titleView.frame.maxY, width: kScreenWidth, height: 0))

            }
            
            if articleModel?.vedioSectionArr.count != 0 {

                for (index, item) in articleModel!.vedioSectionArr.enumerated() {
                    let vedioSectionView = VideoSectionView(frame: CGRect(x: 0, y: self.picSectionView.frame.maxY + 106 * CGFloat(index), width: kScreenWidth, height: 106))
                    contentView.addSubview(vedioSectionView)
                    let itemTag = item.audio!.tags.filter(NSPredicate(format: "type == 0 AND content CONTAINS[c] %@", searchKey)).toArray().first
                    let headString = itemTag?.content
                    vedioSectionView.tapVideoView({ (type) in
                        self.tapAction(type, nil, nil,item)
                    })
                    
                    vedioSectionView.startTime.text = itemTag?.location
                    vedioSectionView.endTime.text = item.audio!.duration
                    vedioSectionView.videoTagView.attributedText = headString!.colorSubString(searchKey, color: UIColor.red)
                    let timePresLeftW = kScreenWidth - 2*70
                    // 总时长
                    let minutes = item.audio!.duration.substring(to: item.audio!.duration.characters.index(item.audio!.duration.startIndex, offsetBy: 2))
                    let second = item.audio!.duration.substring(from: item.audio!.duration.characters.index(item.audio!.duration.startIndex, offsetBy: 3))
                    let allSecond = CGFloat(minutes.toInt()! + second.toInt()!)
                    // 当前时长
                    let currentMinutes = itemTag!.location.substring(to: itemTag!.location.characters.index(itemTag!.location.startIndex, offsetBy: 2))
                    let currentSecond = itemTag!.location.substring(from: itemTag!.location.characters.index(itemTag!.location.startIndex, offsetBy: 3))
                    let currentAllSecond = CGFloat(currentMinutes.toInt()! + currentSecond.toInt()!)
 
                    createGradient(vedioSectionView.timeProgress, frame: CGRect(x: 0, y: 0, width: currentAllSecond * timePresLeftW / allSecond, height: 5))
                    if index == articleModel!.vedioSectionArr.count - 1 {
                        self.videoSectionView = vedioSectionView
                    }
                }
                
            }
        
            layoutIfNeeded()
            let sectionViewH = CGFloat(90 * (articleModel?.textSectionArr.count)!)
            let picSecViewH = CGFloat(250 * (articleModel?.picSectionArr.count)!)
            let videoViewH = CGFloat(106 * (articleModel?.vedioSectionArr.count)!)
            articleModel!.cellRowHight = sectionHeader.h + titleViewH + sectionViewH + picSecViewH + videoViewH + 10

        }
        
        
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = UITableViewCellSelectionStyle.none
        setupUI()
        addConstraints()
        titleView.addTapGesture { (tapgesture:UITapGestureRecognizer) in
            self.tapAction(ClickViewType.title, nil, nil, nil)
        }
        
    }
    
    
    func setupUI() -> Void {
        sectionHeader                   = UIView()
        sectionHeader.backgroundColor   = UIColor.groupTableViewBackground
        contentView.addSubview(sectionHeader)
        titleView                       = UIView()
        contentView.addSubview(titleView)
        articleTitleLabel               = UILabel()
        articleTitleLabel.font          = SYSTEMFONT(18)
        articleTitleLabel.textColor     = RGBCOLORV(0x222222)
        articleTitleLabel.numberOfLines = 0
        articleTitleLabel.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        titleView.addSubview(articleTitleLabel)
        updateTime                      = UILabel()
        updateTime.font                 = SYSTEMFONT(12)
        updateTime.textColor            = RGBCOLORV(0xaaaaaa)
        titleView.addSubview(updateTime)
        rightArrow                      = UIImageView.init(image: UIImage.init(named: "right_arrow"))
        titleView.addSubview(rightArrow)
        
    }
    
    func addConstraints() -> Void {

        sectionHeader.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 8)
        
        articleTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(10)
            make.right.equalTo(rightArrow).offset(-10)
            make.height.lessThanOrEqualTo(20)
        }
        updateTime.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(articleTitleLabel.snp_bottom).offset(8)
            make.width.height.greaterThanOrEqualTo(1)
        }
        rightArrow.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(15)
            make.width.equalTo(8)
            make.centerY.equalToSuperview()
        }

    }
    
    func TappedAction(_ action: @escaping TapAction) {
        tapAction = action
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // 添加渐变层
    func createGradient(_ view:UIView, frame:CGRect) -> Void {
        progressLayer = CALayer()
        progressLayer.frame = frame
        view.layer.addSublayer(progressLayer)
        progressLayer.backgroundColor = RGBCOLORV(0x959595).cgColor
    }
    


    class func cellWithTableView(_ tableview:UITableView) -> UITableViewCell {
        
        let cellID = className + "Mind"
        var cell = tableview.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = Bundle.main.loadNibNamed(className, owner: nil, options: nil)!.last as! SearchArticleCell
        }
        return cell!
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

