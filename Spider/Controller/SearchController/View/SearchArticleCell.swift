//
//  SearchArticleCell.swift
//  Spider
//
//  Created by 童星 on 16/8/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
enum ClickViewType:Int {
    case Title = 0
    case Text = 1
    case Pic = 2
    case Video = 3
}
class SearchArticleCell: UITableViewCell {
    
    typealias TapAction = (type:ClickViewType, textSec: SectionObject?, picSec: PicSectionObject?, videoSec: SectionObject?) -> Void
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
            
            titleView.frame = CGRectMake(0, CGRectGetMaxY(sectionHeader.frame), kScreenWidth, titleViewH)
            
            
            articleTitleLabel.attributedText = articleModel?.title!.colorSubString(searchKey, color: UIColor.redColor())
            let articleUpdateTime = DateUtil.stringWithDateFormat(articleModel!.updateTime, sFormat: kDU_YYYYMMddhhmmss, dFormat: kDU_MMdd)
            updateTime.text = articleUpdateTime
            if articleModel?.textSectionArr.count != 0 {
                for (index,item) in articleModel!.textSectionArr.enumerate() {
                    let headString = item.text
                        let textSectionView = TextSectionView(frame: CGRectMake(0,CGRectGetMaxY(self.titleView.frame) + 90 * CGFloat(index), kScreenWidth, 90))
                        contentView.addSubview(textSectionView)
                        textSectionView.tapTextView { (type) in
                            self.tapAction(type: type, textSec: item, picSec: nil, videoSec: nil)
                        }
                    
                    if headString?.height(kScreenWidth - 30 - 20, font: SYSTEMFONT(16), lineBreakMode: NSLineBreakMode.ByWordWrapping) > 64 {
                        let subSRange:Range = (headString?.rangeOfString(searchKey))!
                        let subIndex:Int    = (headString?.startIndex.distanceTo(subSRange.startIndex))!
                        let oneTosearchSub  = headString?.substringToIndex(headString!.startIndex.advancedBy(subIndex))
                        if oneTosearchSub?.height(kScreenWidth - 30 - 20, font: SYSTEMFONT(16), lineBreakMode: NSLineBreakMode.ByWordWrapping) > 64 {
                            // 1. 前10个字符串
                            let preTenString: String                   = (headString?.substringToIndex(headString!.startIndex.advancedBy(10)))!
                            // 2. 靠近搜索关键字的字符串
                            let range                                  = Range(subSRange.startIndex.advancedBy(-10)...subSRange.startIndex.advancedBy(10))
                            let searchNearByS: String                  = (headString!.substringWithRange(range))
                            let lastStr: String                        = (headString?.substringFromIndex(headString!.endIndex.advancedBy(-5)))!
                            let resultString                           = "\(preTenString)...\(searchNearByS)...\(lastStr)"
                            textSectionView.contentText.attributedText = resultString.colorSubString(searchKey, color: UIColor.redColor())
                            continue
                        }
                        
                        
                    }
                        textSectionView.contentText.attributedText = headString!.colorSubString(searchKey, color: UIColor.redColor())
                    
                    if index == (articleModel?.textSectionArr.count)! - 1 {
                        self.textSectionView = textSectionView
                    }
                }

            }
            else{
            
                textSectionView = TextSectionView(frame: CGRectMake(0,CGRectGetMaxY(self.titleView.frame), kScreenWidth, 0))
            }
            
            if articleModel?.picSectionArr.count != 0 {

                for (index, item) in articleModel!.picSectionArr.enumerate() {
                    let picSectionView = PicSectionView(frame: CGRectMake(0, CGRectGetMaxY(self.textSectionView.frame) + 250 * CGFloat(index), kScreenWidth, 250))
                    contentView.addSubview(picSectionView)
                    let headString = item.tags.filter(NSPredicate(format: "type == 0 AND content CONTAINS[c] %@", searchKey)).toArray().first?.content
                    picSectionView.tapPicView({ (type) in
                        self.tapAction(type: type, textSec: nil, picSec: item, videoSec: nil)
                    })
                    
                    picSectionView.imageTagView.attributedText = headString!.colorSubString(searchKey, color: UIColor.redColor())
                    picSectionView.imageView.spider_setImageWith(PicInfo(object: item))
                    
                    if index == articleModel!.picSectionArr.count - 1 {
                        self.picSectionView = picSectionView
                    }
                }
            }
            else{
            
                picSectionView = PicSectionView(frame: CGRectMake(0,CGRectGetMaxY(self.titleView.frame), kScreenWidth, 0))

            }
            
            if articleModel?.vedioSectionArr.count != 0 {

                for (index, item) in articleModel!.vedioSectionArr.enumerate() {
                    let vedioSectionView = VideoSectionView(frame: CGRectMake(0, CGRectGetMaxY(self.picSectionView.frame) + 106 * CGFloat(index), kScreenWidth, 106))
                    contentView.addSubview(vedioSectionView)
                    let itemTag = item.audio!.tags.filter(NSPredicate(format: "type == 0 AND content CONTAINS[c] %@", searchKey)).toArray().first
                    let headString = itemTag?.content
                    vedioSectionView.tapVideoView({ (type) in
                        self.tapAction(type: type, textSec: nil, picSec: nil, videoSec: item)
                    })
                    
                    vedioSectionView.startTime.text = itemTag?.location
                    vedioSectionView.endTime.text = item.audio!.duration
                    vedioSectionView.videoTagView.attributedText = headString!.colorSubString(searchKey, color: UIColor.redColor())
                    let timePresLeftW = kScreenWidth - 2*70
                    // 总时长
                    let minutes = item.audio!.duration.substringToIndex(item.audio!.duration.startIndex.advancedBy(2))
                    let second = item.audio!.duration.substringFromIndex(item.audio!.duration.startIndex.advancedBy(3))
                    let allSecond = CGFloat(minutes.toInt()! + second.toInt()!)
                    // 当前时长
                    let currentMinutes = itemTag!.location.substringToIndex(itemTag!.location.startIndex.advancedBy(2))
                    let currentSecond = itemTag!.location.substringFromIndex(itemTag!.location.startIndex.advancedBy(3))
                    let currentAllSecond = CGFloat(currentMinutes.toInt()! + currentSecond.toInt()!)
 
                    createGradient(vedioSectionView.timeProgress, frame: CGRectMake(0, 0, currentAllSecond * timePresLeftW / allSecond, 5))
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
        selectionStyle = UITableViewCellSelectionStyle.None
        setupUI()
        addConstraints()
        titleView.addTapGesture { (tapgesture:UITapGestureRecognizer) in
            self.tapAction(type: ClickViewType.Title, textSec: nil, picSec: nil, videoSec: nil)
        }
        
    }
    
    
    func setupUI() -> Void {
        sectionHeader                   = UIView()
        sectionHeader.backgroundColor   = UIColor.groupTableViewBackgroundColor()
        contentView.addSubview(sectionHeader)
        titleView                       = UIView()
        contentView.addSubview(titleView)
        articleTitleLabel               = UILabel()
        articleTitleLabel.font          = SYSTEMFONT(18)
        articleTitleLabel.textColor     = RGBCOLORV(0x222222)
        articleTitleLabel.numberOfLines = 0
        articleTitleLabel.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        titleView.addSubview(articleTitleLabel)
        updateTime                      = UILabel()
        updateTime.font                 = SYSTEMFONT(12)
        updateTime.textColor            = RGBCOLORV(0xaaaaaa)
        titleView.addSubview(updateTime)
        rightArrow                      = UIImageView.init(image: UIImage.init(named: "right_arrow"))
        titleView.addSubview(rightArrow)
        
    }
    
    func addConstraints() -> Void {

        sectionHeader.frame = CGRectMake(0, 0, kScreenWidth, 8)
        
        articleTitleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(10)
            make.right.equalTo(rightArrow).offset(-10)
            make.height.lessThanOrEqualTo(20)
        }
        updateTime.snp_makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(articleTitleLabel.snp_bottom).offset(8)
            make.width.height.greaterThanOrEqualTo(1)
        }
        rightArrow.snp_makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(15)
            make.width.equalTo(8)
            make.centerY.equalToSuperview()
        }

    }
    
    func TappedAction(action: TapAction) {
        tapAction = action
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // 添加渐变层
    func createGradient(view:UIView, frame:CGRect) -> Void {
        progressLayer = CALayer()
        progressLayer.frame = frame
        view.layer.addSublayer(progressLayer)
        progressLayer.backgroundColor = RGBCOLORV(0x959595).CGColor
    }
    


    class func cellWithTableView(tableview:UITableView) -> UITableViewCell {
        
        let cellID = className + "Mind"
        var cell = tableview.dequeueReusableCellWithIdentifier(cellID)
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed(className, owner: nil, options: nil)!.last as! SearchArticleCell
        }
        return cell!
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

