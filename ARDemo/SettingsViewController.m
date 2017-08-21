//
//  SettingsViewController.m
//  ARDemo
//
//  Created by apple on 2017/8/7.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingManager.h"
@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *ambientLightEstimateSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *debugModeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showHitTestAPISwitch;
@property (weak, nonatomic) IBOutlet UISwitch *useOcclusionPlanesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *dragOnInfinitePlanesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *scaleWithPinchGestureSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *use3DOFTrackingSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *useAuto3DOFFallbackSwitch;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self populateSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)populateSettings{
    self.debugModeSwitch.on = [SettingManager getPopulateSettingWithSetting:SettingDebugMode];
    self.ambientLightEstimateSwitch.on = [SettingManager getPopulateSettingWithSetting:SettingAmbientLightEstimation];
    self.showHitTestAPISwitch.on = [SettingManager getPopulateSettingWithSetting:SettingShowHitTestAPI];
    self.useOcclusionPlanesSwitch.on = [SettingManager getPopulateSettingWithSetting:SettingUseOcclusionPlanes];
    self.dragOnInfinitePlanesSwitch.on = [SettingManager getPopulateSettingWithSetting:SettingDragOnInfinitePlanes];
    self.scaleWithPinchGestureSwitch.on = [SettingManager getPopulateSettingWithSetting:SettingScaleWithPinchGesture];
    self.use3DOFTrackingSwitch.on = [SettingManager getPopulateSettingWithSetting:SettingUse3DOFTracking];
    self.useAuto3DOFFallbackSwitch.on = [SettingManager getPopulateSettingWithSetting:SettingUse3DOFFallback];
}
- (IBAction)didChangeSetting:(UISwitch *)sender {
    if (sender == self.ambientLightEstimateSwitch) {
        [SettingManager setSettingWithSetting:SettingAmbientLightEstimation Value:sender.on];
    }else if (sender == self.debugModeSwitch){
         [SettingManager setSettingWithSetting:SettingDebugMode Value:sender.on];
    }else if (sender == self.showHitTestAPISwitch){
         [SettingManager setSettingWithSetting:SettingShowHitTestAPI Value:sender.on];
    }else if (sender == self.useOcclusionPlanesSwitch){
         [SettingManager setSettingWithSetting:SettingUseOcclusionPlanes Value:sender.on];
    }else if (sender == self.dragOnInfinitePlanesSwitch){
         [SettingManager setSettingWithSetting:SettingDragOnInfinitePlanes Value:sender.on];
    }else if (sender == self.scaleWithPinchGestureSwitch){
         [SettingManager setSettingWithSetting:SettingScaleWithPinchGesture Value:sender.on];
    }else if (sender == self.use3DOFTrackingSwitch){
         [SettingManager setSettingWithSetting:SettingUse3DOFTracking Value:sender.on];
    }else if (sender == self.useAuto3DOFFallbackSwitch){
         [SettingManager setSettingWithSetting:SettingUse3DOFFallback Value:sender.on];
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
