// created by Iain Stubbs but based on QEntryTableViewCell.m
//                                
// Copyright 2011 ESCOZ Inc  - http://escoz.com
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this 
// file except in compliance with the License. You may obtain a copy of the License at 
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

@implementation QAutoEntryTableViewCell {
    NSString *_lastAutoComplete;
    QAutoEntryElement *_autoEntryElement;
}

@synthesize autoCompleteField = _autoCompleteField;
@synthesize autoCompleteValues;
@synthesize lastAutoComplete = _lastAutoComplete;


- (void)createSubviews {
    _autoCompleteField = [[DOAutocompleteTextField alloc] init];
    _autoCompleteField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _autoCompleteField.borderStyle = UITextBorderStyleNone;
    _autoCompleteField.delegate = self;
    _autoCompleteField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _autoCompleteField.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [_autoCompleteField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:_autoCompleteField];
    [self setNeedsLayout];
}

- (QAutoEntryTableViewCell *)init {
    self = [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"QuickformEntryElement"];
    if (self!=nil){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self createSubviews];
    }
    return self;
}


- (void)prepareForElement:(QEntryElement *)element inTableView:(QuickDialogTableView *)tableView{
    _quickformTableView = tableView;
    _autoCompleteField.delegate = self;

    _entryElement = element;
    _autoEntryElement = (QAutoEntryElement *)element;

    self.textLabel.text = _entryElement.title;
    self.autoCompleteValues = _autoEntryElement.autoCompleteValues;
    _autoCompleteField.text = _autoEntryElement.textValue;
    _autoCompleteField.placeholder = _autoEntryElement.placeholder;
    _autoCompleteField.autocapitalizationType = _autoEntryElement.autocapitalizationType;
    _autoCompleteField.autocorrectionType = _autoEntryElement.autocorrectionType;
    _autoCompleteField.keyboardType = _autoEntryElement.keyboardType;
    _autoCompleteField.keyboardAppearance = _autoEntryElement.keyboardAppearance;
    _autoCompleteField.secureTextEntry = _autoEntryElement.secureTextEntry;
    _autoCompleteField.autocompleteTextColor = _autoEntryElement.autoCompleteColor;
    _autoCompleteField.returnKeyType = _autoEntryElement.returnKeyType;
    _autoCompleteField.enablesReturnKeyAutomatically = _autoEntryElement.enablesReturnKeyAutomatically;
    
    if (_autoEntryElement.hiddenToolbar){
        _autoCompleteField.inputAccessoryView = nil;
    } else {
        _autoCompleteField.inputAccessoryView = [self createActionBar];
    }

    [self updatePrevNextStatus];
}

- (BOOL)handleActionBarDone:(UIBarButtonItem *)doneButton {
    [_autoCompleteField resignFirstResponder];
    return [super handleActionBarDone:doneButton];
}


-(void)recalculateEntryFieldPosition {
    _entryElement.parentSection.entryPosition = CGRectZero;
    _autoCompleteField.frame = [self calculateFrameForEntryElement];
    CGRect labelFrame = self.textLabel.frame;
    self.textLabel.frame = CGRectMake(labelFrame.origin.x, labelFrame.origin.y,
            _entryElement.parentSection.entryPosition.origin.x-20, labelFrame.size.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self recalculateEntryFieldPosition];
}

- (void)prepareForReuse {
    _quickformTableView = nil;
    _entryElement = nil;
}


-(void)textFieldDidEndEditing:(UITextField *)textField {
    _autoCompleteField.text = self.lastAutoComplete;
    _entryElement.textValue = _autoCompleteField.text;
}

- (void)textFieldEditingChanged:(UITextField *)textField {
    _entryElement.textValue = _autoCompleteField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL result = [super textFieldShouldReturn:textField];
    [textField resignFirstResponder];
    return result;
}
- (BOOL)becomeFirstResponder {
    [_autoCompleteField becomeFirstResponder];
    return YES;
}


#pragma mark - DOAutocompleteTextFieldDelegate
- (NSString *)textField:(DOAutocompleteTextField *)textField completionForPrefix:(NSString *)prefix
{
    NSString* lowPrefix = [prefix lowercaseString];
    
    for (NSString *string in autoCompleteValues)
    {
        NSString* strlower = [string lowercaseString];
        if([strlower hasPrefix:lowPrefix])
        {
            NSRange range = NSMakeRange(0,prefix.length);
            _lastAutoComplete = string;
            return [string stringByReplacingCharactersInRange:range withString:@""];
        }
    }
    _lastAutoComplete = @"";
    return @"";
}

@end
