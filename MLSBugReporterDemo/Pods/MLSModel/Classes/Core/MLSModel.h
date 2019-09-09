//
//  MLSModel.h
//  MLSModel
//
//  Created by MinLison on 2018/5/8.
//

#ifndef MLSModel_h
#define MLSModel_h

#if __has_include(<MLSModel/MLSModel.h>)
    #import <MLSModel/MLSBaseModel.h>
    #if __has_include("NSObject+MLSYYModelMock.h")
        #import <MLSModel/NSObject+MLSYYModelMock.h>
    #endif
#else
    #import "MLSBaseModel.h"
    #if __has_include("NSObject+MLSYYModelMock.h")
        #import "NSObject+MLSYYModelMock.h"
    #endif
#endif


#endif /* MLSModel_h */
