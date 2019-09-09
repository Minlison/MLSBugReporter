//
//  MLSFont.h
//  MinLison
//
//  Created by MinLison on 16/9/5.
//  Copyright © 2016年 MinLison. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  正常系统字体
 */
FOUNDATION_EXTERN UIFont * NormalSystemFont(CGFloat inch_3_5,
                          CGFloat inch_4_0,
                          CGFloat inch_4_7,
                          CGFloat inch_5_5,
                          CGFloat inch_5_8);

/**
 *  粗体
 */
FOUNDATION_EXTERN UIFont * BoldSystemFont(CGFloat inch_3_5,
                        CGFloat inch_4_0,
                        CGFloat inch_4_7,
                        CGFloat inch_5_5,
                        CGFloat inch_5_8);

#define MLSSystemFont(font)           NormalSystemFont(font-2, font-2, font, font, font)
#define MLSBoldSystemFont(font)      BoldSystemFont(font-2, font-2, font, font, font)
/**
 *   UI给出的适配字体
 *   系统字体
 */
#define MLSSystem7Font           MLSSystemFont(7)
#define MLSSystem8Font           MLSSystemFont(8)
#define MLSSystem9Font           MLSSystemFont(9)
#define MLSSystem10Font          MLSSystemFont(10)
#define MLSSystem11Font          MLSSystemFont(11)
#define MLSSystem12Font          MLSSystemFont(12)
#define MLSSystem13Font          MLSSystemFont(13)
#define MLSSystem14Font          MLSSystemFont(14)
#define MLSSystem15Font          MLSSystemFont(15)
#define MLSSystem16Font          MLSSystemFont(16)
#define MLSSystem17Font          MLSSystemFont(17)
#define MLSSystem18Font          MLSSystemFont(18)
#define MLSSystem19Font          MLSSystemFont(19)
#define MLSSystem20Font          MLSSystemFont(20)
#define MLSSystem21Font          MLSSystemFont(21)
#define MLSSystem22Font          MLSSystemFont(22)
#define MLSSystem25Font          MLSSystemFont(25)
#define MLSSystem36Font          MLSSystemFont(36)

/**
 *  系统加粗字体
 */
#define MLSBoldSystem12Font      MLSBoldSystemFont(12)
#define MLSBoldSystem13Font      MLSBoldSystemFont(13)
#define MLSBoldSystem14Font      MLSBoldSystemFont(14)
#define MLSBoldSystem15Font      MLSBoldSystemFont(15)
#define MLSBoldSystem16Font      MLSBoldSystemFont(16)
#define MLSBoldSystem17Font      MLSBoldSystemFont(17)
#define MLSBoldSystem18Font      MLSBoldSystemFont(18)
#define MLSBoldSystem19Font      MLSBoldSystemFont(19)
#define MLSBoldSystem20Font      MLSBoldSystemFont(20)
#define MLSBoldSystem21Font      MLSBoldSystemFont(21)
#define MLSBoldSystem22Font      MLSBoldSystemFont(22)

#define MLSBoldSystem24Font      MLSBoldSystemFont(24)
#define MLSBoldSystem25Font      MLSBoldSystemFont(25)

#define MLSBoldSystem30Font      MLSBoldSystemFont(30)
#define MLSBoldSystem32Font      MLSBoldSystemFont(32)
#define MLSBoldSystem36Font      MLSBoldSystemFont(36)
#define MLSBoldSystem58Font      MLSBoldSystemFont(58)




