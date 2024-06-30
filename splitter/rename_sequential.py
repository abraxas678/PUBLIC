import os

# Specify the directory
directory = '/path/to/your/folder'

# Get a list of all .sh files in the directory (ignoring subfolders)
sh_files = [f for f in os.listdir(directory) if os.path.isfile(os.path.join(directory, f)) and f.endswith('.sh')]

# Sort the files to ensure consistent ordering
sh_files.sort()

# Initialize the expected sequential number
expected_number = 1

# Iterate over the .sh files and rename if necessary
for file in sh_files:
    # Split the file name into number and rest of the name
    parts = file.split('_', 1)
    
    # Check if the first part is a number and if it matches the expected number
    if parts[0].isdigit() and int(parts[0]) == expected_number:
        expected_number += 1
    else:
        # Create the new file name with the expected sequential number
        new_name = f"{expected_number}_{parts[-1]}" if len(parts) > 1 else f"{expected_number}_{file}"
        
        # Rename the file
        os.rename(os.path.join(directory, file), os.path.join(directory, new_name))
        
        # Increment the expected number
        expected_number += 1

print("Renaming completed.")
