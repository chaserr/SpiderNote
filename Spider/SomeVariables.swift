//
//  SomeVariables.swift
//  Spider
//
//  Created by 童星 on 5/25/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import Foundation

let kStatusBarH = CGFloat(20)

// Pic Info View

let kPicBackRO = CGFloat(9)
let kPicBackVO = CGFloat(9)
let kPicBackS  = CGFloat(17)
let kPicBackOy = (kPicThumbH + kStatusBarH - kPicBackS) / 2

let kPicDoneW = CGFloat(50)
let kPicDoneH = CGFloat(26)
let kPicDoneOy = (kPicThumbH + kStatusBarH - kPicDoneH) / 2
let kPicDoneOx = kScreenWidth - kPicDoneW - 10

let kPicThumbS = CGFloat(30)
let kPicThumbHO = CGFloat(10) + kPicThumbS
let kPicThumbOx = kPicBackRO + kPicBackS + CGFloat(18)
let kPicThumbOy = (kPicThumbH + kStatusBarH - kPicThumbS) / 2

let kPicThumbsW = kScreenWidth - kPicThumbOx - kPicDoneW - 20

let kPicAddTagS = CGFloat(40)
let kPicAddTagOx = kScreenWidth - kPicAddTagS - 20
let kPicAddTagOy = kScreenHeight - kPicAddTagS - 20

let kPicAddTagViewH = CGFloat(125)
let kPicTagTypeS = CGFloat(44)

let kPicTagTypeOx2 = CGFloat(kScreenWidth - kPicTagTypeS) / 2
let kPicTagTypeOx1 = kPicTagTypeOx2 - 50 - kPicTagTypeS
let kPicTagTypeOx3 = kPicTagTypeOx2 + 50 + kPicTagTypeS
let kPicTagTypeOy = (kPicAddTagViewH - kPicTagTypeS) / 2 - 10

// pic pic tag
let kPicPicBGW  = CGFloat(63)
let kPicPicTagH = CGFloat(45)
let kPicTagDotS = CGFloat(6)
let kPicPicTagW = kPicPicBGW + kPicTagDotS + CGFloat(5)

// pic audio tag
let kPicAudioBGH = CGFloat(21)
let kPicAudioiConW = CGFloat(9)
let kPicAudioiConH = CGFloat(12)

let kPicAudioBGW = CGFloat(48)
let kPicAudioLabelW = kPicAudioBGW - 12 - kPicAudioiConW - 4

// pic text tag
let kPicTextViewH = CGFloat(90)
let kPicTextTagH = CGFloat(21)

let kPicTextMaxW = CGFloat(96)

let kPicTagEditTW = CGFloat(114)
let kpicTagEditTH = CGFloat(43)

let kPicTagDeleteTW = CGFloat(59)
let kPicTagDeleteTH = CGFloat(43)

// Tag Info View
let kTagCellH = CGFloat(34)
let kImageTagVO = CGFloat(2)
let kImageTagS = kTagCellH - 2 * kImageTagVO

let kPicRecordViewH = CGFloat(218)

let kTagHO = CGFloat(15)

let kTagTimeW = CGFloat(25)
let kTagTimeH = CGFloat(12)

let kTextTagW = kScreenWidth - kTagHO * 4 - kTagTimeW
let kTextTagH = CGFloat(14.5)
let kTextTagTO = (kTagCellH - kTextTagH) / 2

let kTagPlayW = CGFloat(48)
let kTagPlayH = CGFloat(25)

let kTagPlayRO =  kTagHO * 2 + 1 + kTagTimeW - kTagPlayW

let kTagDotS = CGFloat(6)

let kTagMarkW = CGFloat(80)
let kTagMarkH = CGFloat(34)

let kTagMarkButtonW = CGFloat(30)
let kTagMarkButtonH = CGFloat(20)

// Add Text Tag
let kTagTextViewH = CGFloat(120)

// MARK: - Audio Detail
// color
let adc_bg = UIColor.white
let adc_separator = UIColor.color(withHex: 0xf1f1f1)
let adc_title = UIColor.color(withHex: 0x222222)
let adc_toolbar = UIColor.color(withHex: 0x555555)
let adc_toolbar_text = UIColor.color(withHex: 0xd5d5d5)

let adc_tag_time = UIColor.color(withHex: 0xaaaaaa)
let adc_tag_text = UIColor.color(withHex: 0xaaaaaa)

// size
let ado_title_height = CGFloat(60)
let ado_H_text = CGFloat(14)
let ado_toolbar_height = CGFloat(110)




let ado_toolbar_H_time = CGFloat(15)

let ado_toolbar_t_text = CGFloat(28)

let ado_toolbar_play_size = CGFloat(40)
let ado_toolbar_H_button = CGFloat(86)
let ado_toolbar_button_h = CGFloat(20)
let ado_toolbar_button_w = CGFloat(36)
let ado_toolbar_b_button = CGFloat(18)

let ado_toolbar_b_baseline = ado_toolbar_height - CGFloat(38)
let ado_toolbar_t_baseline = CGFloat(32)

let ado_H_tag = CGFloat(15)

let ado_tag_time_w = CGFloat(30)
let ado_tag_time_h = CGFloat(14)

let ado_tag_text_w = CGFloat(200)
let ado_tag_text_h = CGFloat(24)
let ado_tag_image_s = CGFloat(28)

let ado_tag_cell_h = CGFloat(30)

// font size
let adfs_title = CGFloat(12)
let adfs_toolbar_time = CGFloat(10)
let adfs_toolbar_text = CGFloat(13)
let adfs_tag_time = CGFloat(9)
let adfs_tag_text = CGFloat(12)

// MARK: - Mind
// color
let mc_separator = UIColor.color(withHex: 0xf2f2f2)
let mc_bg = UIColor.white
let mc_add_mind = UIColor(white: 1, alpha: 0.9) //UIColor.color(withHex: 0xf0f0f0, alpha: 0.9)
let mc_cell_bg = UIColor.white

// size
let mo_add_mind_height = CGFloat(70)
let mo_add_mind_H_toolbar = CGFloat(30)
let mo_add_mind_H_button = CGFloat(50)

// MARK: - Article
// color
let ac_main = UIColor.color(withHex: 0x3e3e50)
let ac_audio_label = UIColor.color(withHex: 0xa3a3b9)
let ac_head_subtitle = UIColor.color(withHex: 0xc0c0cd)
let ac_head_title = UIColor.color(withHex: 0xffffff)

let ac_head_bg = UIColor.color(withHex: 0x3e3e50)
let ac_text = UIColor.color(withHex: 0x222222)

let ac_separator = UIColor.color(withHex: 0xeaeaea)
let ac_bg = UIColor.white

// height
let ao_audio_height = CGFloat(110)
let ao_right_H_head = CGFloat(16)
let ao_top_V_head = CGFloat(44)
let ao_head_V_subhead = CGFloat(8)
let ao_subhead_V_bottom = CGFloat(30)

let ao_pic_height = CGFloat(250)
let ao_V_pic = CGFloat(6)

let ao_H_text = CGFloat(12)
let ao_V_text = CGFloat(20)

let ao_VH_mark = CGFloat(12)
let ao_mark_height = CGFloat(18)
let ao_mark_width = CGFloat(15)

let ao_audio_player_height = CGFloat(66)

let ao_editor_height = CGFloat(44)
let ao_kb_accessory_height = CGFloat(40)

let ao_add_button_size = CGFloat(30)
let ao_add_button_bg_size = CGFloat(12)

// font size
let afs_head_title = CGFloat(18)
let afs_head_subtitle = CGFloat(9)
let afs_text = CGFloat(13)
let afs_mark = CGFloat(10)

