import os

def extract_activity_and_status(filename):
    # Extract the parts of the filename
    filename_without_extension = os.path.splitext(os.path.basename(filename))[0]
    details = filename_without_extension.split("_")
    
    # Extract the device name, ID, activity, and timestamp from the details
    device_name = details[0]
    user_id = details[1]
    activity = details[2]
    activity_sub = details[3]
    status = details[4]

    return activity, activity_sub, status