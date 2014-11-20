//
//  NewsHeaderView.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/19/14.
//
//

#import <UIKit/UIKit.h>

//this view will hold a row of search bars, to be displayed as a header in a table view
//the bottom two rows will have + and - buttons, to add or remove rows
//it will have a public interface for the height (# searchbars * 44.0) and search bar contents (nsarray)
//the add and subtract functions need to interact with the table view somehow, so that it knows to resize the header
//there should probably also be a maximum number of rows
//placeholder text should be "query 1" "query 2" etc

@interface NewsHeaderView : UIView

- (CGFloat)heightForHeaderView;
@end
