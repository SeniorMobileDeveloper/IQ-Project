//
//  NSObject+DataCoreHandler.m
//  iOS-id
//
//  Created by stephen on 10/20/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "NSObject+DataCoreHandler.h"

@implementation NSObject (DataCoreHandler)

int projectIncrement;
int groupIncrement;
int taskIncrement;
int noteIncrement;
int contactIncrement;
int pdfIncrement;
int photoIncrement;


- (Notes *)insertEmptyNote:(NSManagedObjectContext *)managedObjectContent relationship:(NSString *)typeOf relationshipEntity:(NSEntityDescription *)entity {
    
     // create instance of table
     Notes *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Notes" inManagedObjectContext:managedObjectContent];
     
     // insert
     newEntry.name = @"";
     newEntry.message = @"Untitled Note";
     newEntry.date_created = [NSDate date];
     
     // create relationship with parent table (assume parent object was set by parent)
     if ([typeOf isEqual: @"project"]) {
         newEntry.project = (Projects *)entity;
     } else {
         newEntry.task = (Tasks *)entity;
     }
     
     // error trap
     NSError *error;
     if (![managedObjectContent save:&error]) {
     NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
     }
    
    return newEntry;
}

- (UIImageView *)loadNoteThumbnailByCoreDataPhotos:(NSMutableArray *)photoitems {
    Photos *item = [photoitems objectAtIndex:0];
    
    //NSString *filepath = [item valueForKey:@"photo_path"];
    NSData *imageData = [item valueForKey:@"photo_image"];
    
    //UIImage * img = [UIImage imageWithContentsOfFile: filepath];
    UIImage * img = [[UIImage alloc] initWithData:imageData];
    UIImageView * imageView = [[UIImageView alloc] initWithImage: img];
    
    return imageView;
}

- (BOOL)rebuildDatabaseOnEmpty:(AppDelegate *)appDelegate managedObjectContent:(NSManagedObjectContext *)managedObjectContent delayBuild:(BOOL)delayBuild {

    // get records; load into array
    NSMutableArray *_a_ns_Data = [appDelegate getAllProjects];

    if ([_a_ns_Data count] < 1) {
        if (!delayBuild) {
            [self rebuildDatabase:managedObjectContent];
        }
        
        return true;
    }
    return false;
}

- (BOOL)installDatabasePhotos:(AppDelegate *)appDelegate managedObjectContent:(NSManagedObjectContext *)managedObjectContent
{
    NSMutableArray *_a_ns_Data = [appDelegate getAllPhotos];
    
    if ([_a_ns_Data count] > 0) {
        // save photo to storage if not exist
        
        for (NSInteger i=0; i < [_a_ns_Data count]; i++) {
            Photos *item = [_a_ns_Data objectAtIndex:i];
            
            
            // Store image to disk.
            UIImage *picture = [UIImage imageNamed:item.photo_name];
            
            
            // We opt for JPEG. PNG takes twice as long to convert
            //NSData *picturePNG = UIImagePNGRepresentation(picture);
            NSData *picturePNG = UIImageJPEGRepresentation(picture,1.0);
            // OR divide by 1024
            // NSData *picturePNG = UIImageJPEGRepresentation(picture,1.0)/1024;
            
            
            // rename photos while saving now that the database has been created
            NSString *imageName = [NSString stringWithFormat:@"%@-.jpg",[NSDate date]];
            
            
            // save to database
            
            
            // update
            [item setValue:imageName forKey:@"photo_name"];
            [item setValue:@"" forKey:@"photo_path"];
            [item setValue:[NSDate date] forKey:@"photo_date_created"];
            [item setValue:picturePNG forKey:@"photo_image"];
            
            // relationship already exists
            
            // error trap
            NSError *error = nil;
            if (![managedObjectContent save:&error]) {
                //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
            }
            
            
        }
        
        return true;
    }
    return false;
}

- (BOOL)rebuildDatabase:(NSManagedObjectContext *)managedObjectContent {
    //
    // managedObjectContent
    
    // create arrays
    
    // original
    /*
    NSArray *a_projects = [NSArray arrayWithObjects:@"BOEING 747 (SF-34)", @"CESSNA CITATION (RJ-1H)", @"ARROW COMMANDER (PC-56)", @"CONVAIR CV-580 (MD-87)", @"GULF STREAM III (JS-41)", @"PIPER TWIN TURBO PROP (CR-J1)", nil];
    NSArray *a_groupsforProject1 = [NSArray arrayWithObjects:@"Unknown Inspection 1", nil];
    NSArray *a_groupsforProject2 = [NSArray arrayWithObjects:@"FUSELAGE AND HULL GROUP", @"CABIN AND COCKPIT GROUP", @"ENGINE AND NACELLE GROUP", @"LANDING GEAR GROUP", @"WING AND CENTER SECTION", @"EMPENNAGE GROUP", @"PROPELLER GROUP", @"COMMUNICATION AND NAVIGATION GROUP", nil];
    NSArray *a_groupsforProject3 = [NSArray arrayWithObjects:@"Unknown Inspection 3", @"Unknown Inspection 4", nil];
    NSArray *a_groupsforProject4 = [NSArray arrayWithObjects:@"Unknown Inspection 5", nil];
    NSArray *a_groupsforProject5 = [NSArray arrayWithObjects:@"Unknown Inspection 6", nil];
    NSArray *a_groupsforProject6 = [NSArray arrayWithObjects:@"Unknown Inspection 7", @"Unknown Inspection 8", nil];
    
    NSArray *a_tasksforGroup1 = [NSArray arrayWithObjects:@"Task 1", @"Unknown Task 1", nil];
    NSArray *a_tasksforGroup2 = [NSArray arrayWithObjects:@"Are the systems and components properly installed, free of apparent defects, and in sastisfactory operation?",@"Is the fabric and skin free of deterioration, distortion, other evidence of failure, and defective or insecure attachment fittings?", @"Are the envelope gas bags, ballast tanks, and related parts in good condition?", nil];
    
    NSArray *a_tasksforGroup3 = [NSArray arrayWithObjects:@"Unknown Task 4", @"Unknown Task 5", nil];
    NSArray *a_tasksforGroup4 = [NSArray arrayWithObjects:@"Unknown Task 5", @"Unknown Task 6", nil];
    NSArray *a_tasksforGroup5 = [NSArray arrayWithObjects:@"Unknown Task 7", nil];
    NSArray *a_tasksforGroup6 = [NSArray arrayWithObjects:@"Unknown Task 8", nil];
    NSArray *a_tasksforGroup7 = [NSArray arrayWithObjects:@"Unknown Task 9", nil];
     
     NSArray *a_g = [[NSArray alloc] initWithObjects:a_groupsforProject1,a_groupsforProject2,a_groupsforProject3,a_groupsforProject4,a_groupsforProject5,a_groupsforProject6, nil];
     NSArray *a_t1 = [[NSArray alloc] initWithObjects:a_tasksforGroup1, nil];
     NSArray *a_t2 = [[NSArray alloc] initWithObjects:a_tasksforGroup2, a_tasksforGroup3, a_tasksforGroup4, a_tasksforGroup5, nil];
     NSArray *a_t3 = [[NSArray alloc] initWithObjects:a_tasksforGroup6, a_tasksforGroup7, nil];
    */
    
    NSArray *a_projects = [NSArray arrayWithObjects:@"BOEING 747 (SF-34)",
                           @"CESSNA CITATION (RJ-1H)",
                           @"ARROW COMMANDER (PC-56)",
                           @"CONVAIR CV-580 (MD-87)",
                           @"GULF STREAM III (JS-41)",
                           @"PIPER TWIN TURBO PROP (CR-J1)",
                           nil];
    NSArray *a_groupsforProject1 = [NSArray arrayWithObjects:@"Certificates",
                                    @"Engines",
                                    @"Equipment and Cargo Compartments",
                                    @"Flight Deck",
                                    @"Fuselage, Exterior, Engines and Propellers",
                                    @"Fuselage Interior",
                                    nil];
    NSArray *a_groupsforProject2 = a_groupsforProject1;
    NSArray *a_groupsforProject3 = a_groupsforProject1;
    NSArray *a_groupsforProject4 = a_groupsforProject1;
    NSArray *a_groupsforProject5 = a_groupsforProject1;
    NSArray *a_groupsforProject6 = a_groupsforProject1;
    
    // original
    /*
     NSArray *a_tasksforGroup1 = [NSArray arrayWithObjects:@"Are the systems and components properly installed, free of apparent defects, and in sastisfactory operation?",@"Is the fabric and skin free of deterioration, distortion, other evidence of failure, and defective or insecure attachment fittings?", @"Are the envelope gas bags, ballast tanks, and related parts in good condition?", nil];
     */
    // certificates
    NSArray *a_tasksforGroup1 = [NSArray arrayWithObjects:@"Is the Certificate of Airworthiness complete?",
                                 @"Is the Current Aircraft Registration complete?",
                                 @"Is the C of A for Export (if applicable) complete?",
                                 @"Is the Noise Limitation Certificate (AFM page) complete?",
                                 @"Is the Radio Station License complete?",
                                 @"Is the Certificate of Sanitary Construction (if applicable) complete?",
                                 @"Is the Aircraft deregistration confirmation (if applicable) complete?",
                                 nil];
    // Engines
    NSArray *a_tasksforGroup2 = [NSArray arrayWithObjects:@"Is the engine clean and in good condition?",
                                 @"Is there any loose or missing equipment?",
                                 @"Is there any breakage?",
                                 @"Is there any sign of fluid leaks or corrosion?",
                                 @"Have all of the parts been properly installed?",
                                 @"Are there any other indications of defects?",
                                 @"Are the fire extingusihing system components and extinguishing agent indicators working properly?",
                                 @"Are there any dents in the turbine blades?",
                                 @"Is there any erosion in the turbine blades?",
                                 @"Are there any nicks or other irregularities in the turbine blades?",
                                 nil];
    // Equipment and Cargo Compartments
    NSArray *a_tasksforGroup3 = [NSArray arrayWithObjects:
                                 @"Are the electronic/electrical components including wiring and connectors in good condition?",
                                 @"Are the electronic/electrical components including wiring and connectors properly bonded?",
                                 @"Are the electronic/electrical components including wiring and connectors secure?",
                                 @"Is the wiring is properly grouped to airframe structure?",
                                 @"Is the wiring is properly bundled, to airframe structure?",
                                 @"Is the wiring is properly  routed to airframe structure?",
                                 @"Is the wiring is properly secured to airframe structure?",
                                 @"Is there any visible metal shavings or other debris that can cause electrical shorts and fire?",
                                 @"Is the exposed airframe structure (forward pressure bulkhead, if accessible) in displaying any corrosion inhibiting compound (CIC) application?",
                                 @"Is the exposed airframe structure (forward pressure bulkhead, if accessible) in  good general condition?  ",
                                 @"Is the exposed airframe structure (forward pressure bulkhead, if accessible) in  showing any evidence of fluid leaks and damage?",
                                 @"Are the insulation blankets in good condition?",
                                 @"Are the insulation blankets exhibiting any liquid saturation?",
                                 nil];
    // Flight Deck
    NSArray *a_tasksforGroup4 = [NSArray arrayWithObjects:@"Is the instrument arrangement and visibility of flight and navigation instruments in accordance with the applicable regulations?",
                                 nil];
    // Fuselage, Exterior, Engines and Propellers
    NSArray *a_tasksforGroup5 = [NSArray arrayWithObjects:@"Is the radome in good condition?",
                                 @"Is the erosion cap in good condition?",
                                 @"Are the lightning diverter strips in good condition?",
                                 @"Are any exposed electronic/electrical components in good condition?  (antennas, weather radar wave-guide, cable and wire bundles, connectors, etc.).",
                                 @"Are exposed electronic/electrical components secure?   (antennas, weather radar wave-guide, cable and wire bundles, connectors, etc.).",
                                 @"Are exposed electronic/electrical components for properly bonded/grounded?  (antennas, weather radar wave-guide, cable and wire bundles, connectors, etc.).",
                                 @"Is the exposed airframe area (forward-pressure bulkhead) in good condition?",
                                 @"Is the exposed airframe area (forward-pressure bulkhead) corroded?",
                                 @"Is the exposed airframe area (forward-pressure bulkhead)  damaged?",
                                 @"Is the exposed airframe area (forward-pressure bulkhead) requiring repairs?",
                                 nil];
    // Fuselage Interior
    NSArray *a_tasksforGroup6 = [NSArray arrayWithObjects:@"Is the Original Airworthiness Certificate displayed at the cabin or flight deck entrance?",
                                 @"Is the Original Airworthiness Certificate legible to passengers or crew ?",
                                 @"Is the Flight Deck Voice Recorder in proper condition? (e.g., color of recorder case and reflective tape), security, and configuration.",
                                 nil];
    
    
    NSArray *a_g = [[NSArray alloc] initWithObjects:a_groupsforProject1,a_groupsforProject2,a_groupsforProject3,a_groupsforProject4,a_groupsforProject5,a_groupsforProject6, nil];
    NSArray *a_t1 = [[NSArray alloc] initWithObjects:a_tasksforGroup1, a_tasksforGroup2, a_tasksforGroup3, a_tasksforGroup4, a_tasksforGroup5, a_tasksforGroup6, nil];
    
    ////////
    // NOTES
    ////////
    
    // certificates
    NSArray *a_notes1 = [NSArray arrayWithObjects:@"Completed Certificate",
                         @"",
                         @"",
                         @"",
                         @"",
                         @"",
                         @"",
                         nil];
    // Engines
    NSArray *a_notes2 = [NSArray arrayWithObjects:@"",
                         @"",
                         @"",
                         @"Leaking noted at indicated spots",
                         @"",
                         @"Leading edges show nicks on the turbines",
                         @"",
                         @"Nicks and notches on turbines",
                         @"No erosion noted",
                         @"No noted irregularities",
                         nil];
    // Equipment and Cargo Compartments
    NSArray *a_notes3 = [NSArray arrayWithObjects:@"Wiring in cargo in need of repair due to loose pit bull during previous flight",
                         @"",
                         @"",
                         @"Wiring is properly grouped and showing no issues",
                         @"",
                         @"",
                         @"",
                         @"",
                         @"",
                         @"",
                         @"Wiring accessible and in fair condition",
                         @"",
                         @"Insulation blankets are in good condition",
                         nil];
    // Flight Deck
    NSArray *a_notes4 = [NSArray arrayWithObjects:@"The arrangement and placement of instruments appear in accordance and functioning properly",
                         nil];
    // Fuselage, Exterior, Engines and Propellers
    NSArray *a_notes5 = [NSArray arrayWithObjects:@"No noted damages",
                         @"",
                         @"",
                         @"See damaged wire and corrosion",
                         @"",
                         @"Wires appear to be properly grounded and bonded",
                         @"",
                         @"",
                         @"",
                         @"",
                         nil];
    // Fuselage Interior
    NSArray *a_notes6 = [NSArray arrayWithObjects:
                         @"Cert noted and posted properly",
                         @"",
                         @"Data recorder mounted properly and in good condition",
                         nil];
    
    
    NSArray *a_notesForTask = [NSArray arrayWithObjects:
                               a_notes1,
                               a_notes2,
                               a_notes3,
                               a_notes4,
                               a_notes5,
                               a_notes6,
                                 nil];
    
    
    /////////
    // PHOTOS
    /////////
    
    // certificates
    NSArray *a_photos1 = [NSArray arrayWithObjects:@"Airworthiness_certificate_sample.jpg",
                         @"",
                         @"",
                         @"",
                         @"",
                         @"",
                         @"",
                         nil];
    // Engines
    NSArray *a_photos2 = [NSArray arrayWithObjects:@"",
                         @"",
                         @"",
                         @"leaking_turbine2.jpg",
                         @"",
                         @"0310_ColumbiaU_Fig2.jpg",
                         @"",
                         @"images-03.jpg",
                         @"jet-engine-turbine-blades-24525411.jpg",
                         @"image-06-large.jpg",
                         nil];
    // Equipment and Cargo Compartments
    NSArray *a_photos3 = [NSArray arrayWithObjects:@"wiring_in_cargo.jpg",
                         @"",
                         @"",
                         @"wiring.jpg",
                         @"",
                         @"",
                         @"",
                         @"",
                         @"",
                         @"",
                         @"rear_pressure_bulkhead.jpg",
                         @"",
                         @"insulation_blanket.jpg",
                         nil];
    // Flight Deck
    NSArray *a_photos4 = [NSArray arrayWithObjects:@"Flight_Instrument_panel.jpg",
                         nil];
    // Fuselage, Exterior, Engines and Propellers
    NSArray *a_photos5 = [NSArray arrayWithObjects:@"radome_nose.jpg",
                         @"",
                         @"",
                         @"aair200501000_001",
                         @"",
                         @"wiring.jpg",
                         @"",
                         @"",
                         @"",
                         @"",
                         nil];
    // Fuselage Interior
    NSArray *a_photos6 = [NSArray arrayWithObjects:
                         @"Airworthiness_certificate_sample.jpg",
                         @"",
                         @"flight_data_recorder.jpg",
                         nil];
    
    NSArray *a_photosForNotes = [NSArray arrayWithObjects:
                                 a_photos1,
                                 a_photos2,
                                 a_photos3,
                                 a_photos4,
                                 a_photos5,
                                 a_photos6,
                                 nil];
 
    // Create company

    Company *companyEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Company" inManagedObjectContext:managedObjectContent];
    
    // insert (replace with data from text field when ready)
    companyEntry.name = @"Quality Assurance";
    companyEntry.id = [NSNumber numberWithInt:1]; // assign remote database id
    
    
    // error trap
    NSError *error;
    if (![managedObjectContent save:&error]) {
        NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
    }

    // initialize variables
    projectIncrement = 1;
    groupIncrement = 1;
    taskIncrement = 1;
    noteIncrement = 1;
    contactIncrement = 1;
    pdfIncrement = 1;
    photoIncrement = 1;
    
    // create projects
    //BOOL isFirstDataSet = false;
    for (NSInteger i=0; i < [a_projects count]; i++) {
        
        NSString *projectItem = [a_projects objectAtIndex:i];
        
        // create instance of project table
        Projects *projectEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Projects" inManagedObjectContext:managedObjectContent];
        
        // insert (replace with data from text field when ready)
        projectEntry.project_name = projectItem;
        projectEntry.project_active = [NSNumber numberWithBool:YES];
        projectEntry.id = [NSNumber numberWithInt:projectIncrement]; // assign increment that will match remote database id
        projectEntry.company = companyEntry;
        
        projectIncrement++;
        
        // as a sample, apply info-panel data to first project only
        // [edited: apply to all]
        //if (!isFirstDataSet) {
        //    isFirstDataSet = true;
            [self applyDataSampleToEntry:projectEntry managedobject:managedObjectContent];
        //}
        
        // error trap
        NSError *error;
        if (![managedObjectContent save:&error]) {
            //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
        }
        
        // create associated group for projects
        NSArray *a_g_items = [a_g objectAtIndex:i];
        //if(i==0) {
            [self createGroupsAndTasksForProject:projectEntry items:a_g_items tasks:a_t1 noteItems:a_notesForTask photoItems:a_photosForNotes managedobject:managedObjectContent];
        //} else if (i==1) {
        //    [self createGroupsAndTasksForProject:projectEntry items:a_g_items tasks:a_t2 managedobject:managedObjectContent];
        //}
    }
    
    // install packages
    [self createPdfs:managedObjectContent];
    
    return true; // on complete
}
- (void)applyDataSampleToEntry:(Projects *)projectEntry managedobject:(NSManagedObjectContext *)managedObjectContent {
    
    NSArray *a_pictures = [NSArray arrayWithObjects:@"Boeing-787-Dreamliner-Cockpit.jpg", @"106dizq.jpg", @"airplane-graveyard-tarmac-wing.jpg", @"A380T900-07.jpg", @"aair200501000_001.jpg", @"ana787cockpit13.jpg", nil];
    NSError *error;
    
    // create instance of table
    Notes *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Notes" inManagedObjectContext:managedObjectContent];
    
    
    // add note
    newNote.name = @"";
    newNote.message = @"Untitled Note";
    newNote.date_created = [NSDate date];
    
    // create relationship with parent table
    newNote.project = projectEntry;
    newNote.id = [NSNumber numberWithInt:noteIncrement]; // assign increment that will match remote database id
    
    noteIncrement++;
    
    // error trap
    error = nil;
    if (![managedObjectContent save:&error]) {
        //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
    }
    
    
    // create image associations
    for (NSInteger i=0; i < [a_pictures count]; i++) {
        NSString *item = [a_pictures objectAtIndex:i];
        
        // Store image to disk.
        UIImage *picture = [UIImage imageNamed:item];
        NSData *picturePNG = UIImagePNGRepresentation(picture);
        
        // We do not alter the image name when building the initial database. Photos will not
        // be transferred to the device storage, so we need to be sure we know the exact name
        // of the existing image so we can install it after the database has been created.
        NSString *imageName = item; // [NSString stringWithFormat:@"%@-.png",[NSDate date]];
      
        
        // save to database
        Photos *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:managedObjectContent];
        
        // insert
        newPhoto.photo_name = imageName;
        newPhoto.photo_path = @""; // [imageData objectForKey:@"path"]; // path;
        newPhoto.photo_date_created = [NSDate date];
        newPhoto.photo_image = picturePNG;
        newPhoto.id = [NSNumber numberWithInt:photoIncrement]; // assign increment that will match remote database id
        
        photoIncrement++;
        
        // create relationship with parent table (assume parent object was set by parent)
        newPhoto.note = newNote;
        
        // error trap
        error = nil;
        if (![managedObjectContent save:&error]) {
            //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
        }
        
    }
    
}
- (void)createPdfs:(NSManagedObjectContext *)managedObjectContent {
    NSString *agreementItem;
    Pdf *itemEntry;
    NSError *error;
    NSInteger i;
    
    // history
    NSArray *a_pdfs_history = [NSArray arrayWithObjects:@"HistoryReportSample_05sm.pdf", nil];
    for (i=0; i < [a_pdfs_history count]; i++) {
        
        agreementItem = [a_pdfs_history objectAtIndex:i];
        
        // create instance of project table
        itemEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Pdf" inManagedObjectContext:managedObjectContent];
        
        // insert (replace with data from text field when ready)
        itemEntry.pdf_name = agreementItem;
        itemEntry.pdf_filename = agreementItem;
        itemEntry.pdf_type = [NSNumber numberWithInt:1];
        itemEntry.id = [NSNumber numberWithInt:pdfIncrement]; // assign increment that will match remote database id
        
        pdfIncrement++;
        
        // error trap
        if (![managedObjectContent save:&error]) {
            //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
        }
    }
    
    // agreement
    NSArray *a_pdfs_agreement = [NSArray arrayWithObjects:@"AircraftLeaseSample.pdf", nil];
    for (i=0; i < [a_pdfs_agreement count]; i++) {
        
        agreementItem = [a_pdfs_agreement objectAtIndex:i];
        
        // create instance of project table
        itemEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Pdf" inManagedObjectContext:managedObjectContent];
        
        // insert (replace with data from text field when ready)
        itemEntry.pdf_name = agreementItem;
        itemEntry.pdf_filename = agreementItem;
        itemEntry.pdf_type = [NSNumber numberWithInt:2];
        itemEntry.id = [NSNumber numberWithInt:pdfIncrement]; // assign increment that will match remote database id
        
        pdfIncrement++;
        
        // error trap
        if (![managedObjectContent save:&error]) {
            //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
        }
    }
    
    // resource
    NSArray *a_pdfs_resource = [NSArray arrayWithObjects:@"Aircraft Wiring practices.pdf", @"BOM.pdf", @"electrical-system-schematic.pdf", nil];
    for (i=0; i < [a_pdfs_resource count]; i++) {
        
        agreementItem = [a_pdfs_resource objectAtIndex:i];
        
        // create instance of project table
        itemEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Pdf" inManagedObjectContext:managedObjectContent];
        
        // insert (replace with data from text field when ready)
        itemEntry.pdf_name = agreementItem;
        itemEntry.pdf_filename = agreementItem;
        itemEntry.pdf_type = [NSNumber numberWithInt:3];
        itemEntry.id = [NSNumber numberWithInt:pdfIncrement]; // assign increment that will match remote database id
        
        pdfIncrement++;
        
        // error trap
        if (![managedObjectContent save:&error]) {
            //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
        }
    }
    
}
- (void)createGroupsAndTasksForProject:(Projects *)project items:(NSArray *)items tasks:(NSArray *)tasks noteItems:(NSArray *)noteItems photoItems:(NSArray *)photoItems managedobject:(NSManagedObjectContext *)managedObjectContent{
    
    for (NSInteger i=0; i < [items count]; i++) {
        
        NSString *item = [items objectAtIndex:i];
        
        // create instance of table
        ProjectGroup *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"ProjectGroup" inManagedObjectContext:managedObjectContent];
        
        // insert
        newEntry.projectgroup_name = item;
        newEntry.projectgroup_active = [NSNumber numberWithBool:YES];
        newEntry.id = [NSNumber numberWithInt:groupIncrement]; // assign increment that will match remote database id
        
        groupIncrement++;
        
        // create relationship with project
        newEntry.project = project;
        
        // error trap
        NSError *error;
        if (![managedObjectContent save:&error]) {
            //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
        }
        
        // create associated tasks
        if (i<[tasks count]) {
            NSArray *a_t_items = [tasks objectAtIndex:i];
            
            // 1099 - makeshift generator. We assume everything. Notes and Photos arrays exists for
            // every task. They can be empty but we send them with the data
            NSArray *a_notes  = [noteItems objectAtIndex:i];
            NSArray *a_photos  = [photoItems objectAtIndex:i];
            
            [self createTasksForGroup:newEntry items:a_t_items noteItems:a_notes photoItems:a_photos managedobject:managedObjectContent];
        }
    }
}
- (void)createTasksForGroup:(ProjectGroup *)group items:(NSArray *)items noteItems:(NSArray *)noteItems photoItems:(NSArray *)photoItems managedobject:(NSManagedObjectContext *)managedObjectContent {
    
    for (NSInteger i=0; i < [items count]; i++) {
        
        NSString *item = [items objectAtIndex:i];
        
        Tasks *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Tasks" inManagedObjectContext:managedObjectContent];
        
        // insert
        newEntry.task_name = @"";
        newEntry.task_desc = item;
        newEntry.task_active = [NSNumber numberWithBool:YES];
        newEntry.task_complete = 0; //[NSNumber numberWithBool:NO];
        newEntry.id = [NSNumber numberWithInt:taskIncrement]; // assign increment that will match remote database id
        
        taskIncrement++;
        
        // create relationship with project (assume selectedProject was set by parent)
        newEntry.group = group;
        
        // error trap
        NSError *error;
        if (![managedObjectContent save:&error]) {
            //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
        }
        
        // create associated notes
        /*
        if (i<[noteItems count]) {
            NSArray *a_notes  = [noteItems objectAtIndex:i]; // we have structured sub arrays to coincide with item arrays
            if ([a_notes count]>0) {
                NSArray *a_photos  = [photoItems objectAtIndex:i]; // we have structured sub arrays to coincide with item arrays
                [self createNotesForTasks:newEntry items:a_notes photos:a_photos managedobject:managedObjectContent];
            }
        }
        */
        // 1099 at the moment, the notes and phots are 1-to-1. There is not an extra
        // array. Go back to the above routine and uncomment to work with array in array
        if (i<[noteItems count]) {
            NSString *noteMessage = [noteItems objectAtIndex:i];
            if (![noteMessage isEqual:@""]) {
                [self createNotesForTasks:newEntry note:noteMessage photo:[photoItems objectAtIndex:i] managedobject:managedObjectContent];
            }
        }
        
    }
}

- (void)createNotesForTasks:(Tasks *)task note:(NSString *)noteMessage photo:(NSString *)photoName managedobject:(NSManagedObjectContext *)managedObjectContent {

    NSError *error;
    
    
    
    
    //for (NSInteger i=0; i < [items count]; i++) {
        
        NSString *message = noteMessage; //[items objectAtIndex:i];
        
        // create instance of table
        Notes *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Notes" inManagedObjectContext:managedObjectContent];
        
        
        // add note
        newNote.name = @"";
        newNote.message = message;
        newNote.date_created = [NSDate date];
        newNote.id = [NSNumber numberWithInt:noteIncrement]; // assign increment that will match remote database id
    
        noteIncrement++;
    
        // create relationship with parent table
        newNote.task = task;
        
        
        // error trap
        error = nil;
        if (![managedObjectContent save:&error]) {
            //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
        }
        
        
        // create image associations
        //NSArray *a_pictures  = [photos objectAtIndex:i]; // we have structured photo arrays to coincide with item arrays
        
        //for (NSInteger j=0; j < [a_pictures count]; j++) {
            NSString *img = photoName; //[a_pictures objectAtIndex:j];
            
            // Store image to disk.
            UIImage *picture = [UIImage imageNamed:img];
            NSData *picturePNG = UIImagePNGRepresentation(picture);
    
            // We do not alter the image name when building the initial database. Photos will not
            // be transferred to the device storage, so we need to be sure we know the exact name
            // of the existing image so we can install it after the database has been created.
            NSString *imageName = img; // [NSString stringWithFormat:@"%@-.png",[NSDate date]];
            
            
            // save to database
            Photos *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:managedObjectContent];
            
            // insert
            newPhoto.photo_name = imageName;
            newPhoto.photo_path = @""; // [imageData objectForKey:@"path"]; // path;
            newPhoto.photo_date_created = [NSDate date];
            newPhoto.photo_image = picturePNG;
            newPhoto.id = [NSNumber numberWithInt:photoIncrement]; // assign increment that will match remote database id
    
            photoIncrement++;
    
            // create relationship with parent table (assume parent object was set by parent)
            newPhoto.note = newNote;
            
            // error trap
            error = nil;
            if (![managedObjectContent save:&error]) {
                //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
            }
            
        //}
        
        
    //}
 
    
}


@end
