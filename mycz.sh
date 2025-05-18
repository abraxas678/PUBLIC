#!/bin/bash

MYCZ_DIR="$HOME/.mycz"
if [ ! -d "$MYCZ_DIR" ]; then
    error "MYCZ directory not found. Please run 'mycz.sh init' first."
    exit 1
fi

# --- Color Definitions ---
# Check if stdout is a terminal and tput is available
if [ -t 1 ] && command -v tput &>/dev/null; then
    COLOR_RESET=$(tput sgr0)
    COLOR_RED=$(tput setaf 1)
    COLOR_GREEN=$(tput setaf 2)
    COLOR_YELLOW=$(tput setaf 3)
    COLOR_BLUE=$(tput setaf 4)
    COLOR_BOLD=$(tput bold)
else
    COLOR_RESET=""
    COLOR_RED=""
    COLOR_GREEN=""
    COLOR_YELLOW=""
    COLOR_BLUE=""
    COLOR_BOLD=""
fi

# --- Output Helper Functions ---
_print_msg() {
    local color="$1"
    local prefix="$2"
    shift 2
    printf "%s%s%s%s\\n" "$color" "$prefix" "$*" "$COLOR_RESET" >&2 # Print to stderr to separate from potential command output
}

info() { _print_msg "$COLOR_BLUE" "[INFO] " "$@"; }
success() { _print_msg "$COLOR_GREEN" "[ OK ] " "$@"; }
warning() { _print_msg "$COLOR_YELLOW" "[WARN] " "$@"; }
error() { _print_msg "$COLOR_RED" "[ERR!] " "$@"; }
header() { printf "\\n%s%s%s%s\\n" "$COLOR_BOLD" "$COLOR_BLUE" "--- $1 ---" "$COLOR_RESET" >&2; }
item() { printf "  %s[*]%s %s\\n" "$COLOR_YELLOW" "$COLOR_RESET" "$@" >&2; }
sub_item() { printf "    %s-%s %s\\n" "$COLOR_BLUE" "$COLOR_RESET" "$@" >&2; }
important() { _print_msg "$COLOR_YELLOW" "${COLOR_BOLD}[IMPT] " "$@"; }

# Constants for large file handling
MYCZ_CHUNK_SUFFIX=".myczpart."
MYCZ_CHUNK_SIZE_SPLIT="47M" # For split command
MYCZ_MAX_FILE_SIZE_BYTES=$((50 * 1024 * 1024)) # 50MB limit, split into 47MB chunks

# Function to check age setup
check_age_setup() {
  header "Age Setup Check"
  if ! command -v age &> /dev/null; then
    error "age command not found."
    info "Please install age: https://github.com/FiloSottile/age#installation"
    info "On Debian/Ubuntu: sudo apt install age"
    info "On macOS (Homebrew): brew install age"
    exit 1
  fi

  # These will be populated by this function
  unset INTERNAL_AGE_RECIPIENTS
  unset INTERNAL_AGE_IDENTITY_FILE
  
  DEFAULT_KEY_FILE="$HOME/.mycz/mycz_age_key.txt"

  if [ -n "$MYCZ_AGE_RECIPIENTS" ]; then
    info "Using MYCZ_AGE_RECIPIENTS environment variable: $MYCZ_AGE_RECIPIENTS"
    INTERNAL_AGE_RECIPIENTS="$MYCZ_AGE_RECIPIENTS"
    # Check if MYCZ_AGE_RECIPIENTS specifies an identity file using -i
    # This is a simple parser; assumes -i is followed by a space then the path.
    if [[ "$MYCZ_AGE_RECIPIENTS" == *"-i "* ]]; then
      local potential_id_path
      # Extract path after -i. Handles paths with spaces if MYCZ_AGE_RECIPIENTS is carefully quoted.
      # Using a more robust way to extract the argument after -i
      eval "set -- $MYCZ_AGE_RECIPIENTS" # Break MYCZ_AGE_RECIPIENTS into arguments
      while [ "$#" -gt 0 ]; do
        if [ "$1" = "-i" ] && [ -n "$2" ]; then
          potential_id_path="$2"
          break
        fi
        shift
      done

      if [ -n "$potential_id_path" ] && [ -f "$potential_id_path" ]; then
        success "Found identity file specified in MYCZ_AGE_RECIPIENTS: $potential_id_path"
        INTERNAL_AGE_IDENTITY_FILE="$potential_id_path"
      elif [ -n "$potential_id_path" ]; then
        warning "MYCZ_AGE_RECIPIENTS specifies identity file '$potential_id_path' but it was not found."
      fi
    fi
  else
    info "MYCZ_AGE_RECIPIENTS environment variable is not set."
    if [ -f "$DEFAULT_KEY_FILE" ]; then
      info "Found default key file: $DEFAULT_KEY_FILE"
      local derived_pub_key
      derived_pub_key=$(age-keygen -y "$DEFAULT_KEY_FILE" 2>/dev/null)
      if [ -n "$derived_pub_key" ]; then
        success "Successfully derived public key: $derived_pub_key"
        # For encryption, if 'add --encrypt' is the command context
        if [[ "$COMMAND" == "add" && "$ENCRYPTED" == "true" ]]; then
            info "Using this public key for encryption in current session."
            important "For future use, please consider setting: export MYCZ_AGE_RECIPIENTS=\"-r $derived_pub_key\""
            INTERNAL_AGE_RECIPIENTS="-r $derived_pub_key"
        fi
        # For decryption
        INTERNAL_AGE_IDENTITY_FILE="$DEFAULT_KEY_FILE"
        info "Using $DEFAULT_KEY_FILE as identity for decryption in current session."
      else
        error "Could not derive public key from $DEFAULT_KEY_FILE. The file might be corrupted or not a valid age private key."
      fi
    else # No MYCZ_AGE_RECIPIENTS and no default key file
      info "Default key file $DEFAULT_KEY_FILE not found."
      # Only prompt for key generation if we are in an interactive session for an 'add --encrypt' operation
      if [[ "$COMMAND" == "add" && "$ENCRYPTED" == "true" ]]; then
          if [ -t 0 ] && [ -t 1 ]; then # Check if stdin and stdout are TTYs
            # Use printf for prompt to ensure consistent behavior
            printf "%s%s%s" "$COLOR_YELLOW" "Generate a new age key pair at $DEFAULT_KEY_FILE? (y/N): " "$COLOR_RESET"
            read -r generate_key_prompt
            echo # Newline after prompt
            if [[ "$generate_key_prompt" =~ ^[Yy]$ ]]; then
              info "Generating new key pair at $DEFAULT_KEY_FILE ..."
              mkdir -p "$(dirname "$DEFAULT_KEY_FILE")"
              if age-keygen -o "$DEFAULT_KEY_FILE"; then
                local generated_pub_key
                generated_pub_key=$(age-keygen -y "$DEFAULT_KEY_FILE")
                if [ -n "$generated_pub_key" ]; then
                  success "Key pair generated successfully."
                  important "Private key: $DEFAULT_KEY_FILE (KEEP THIS FILE SECRET AND BACK IT UP!)"
                  important "Public key: $generated_pub_key"
                  info "Using this new public key for encryption in current session."
                  important "IMPORTANT: For future use, add this to your shell profile (e.g., ~/.bashrc or ~/.zshrc):"
                  important "           export MYCZ_AGE_RECIPIENTS=\"-r $generated_pub_key\""
                  INTERNAL_AGE_RECIPIENTS="-r $generated_pub_key"
                  INTERNAL_AGE_IDENTITY_FILE="$DEFAULT_KEY_FILE" # Also set for immediate decryption use if needed
                  info "Using $DEFAULT_KEY_FILE as identity for decryption in current session."
                else
                  error "Key generated but could not derive public key. This is unexpected."
                fi
              else
                error "Failed to generate key pair."
              fi
            else
              info "Key generation declined. Cannot proceed with encrypting new files."
            fi
          else # Non-interactive for 'add --encrypt'
             warning "Non-interactive session. Cannot prompt for key generation for 'add --encrypt'."
             warning "Please set MYCZ_AGE_RECIPIENTS or ensure $DEFAULT_KEY_FILE exists and is valid."
          fi
      fi # End 'add --encrypt' specific key generation prompt
    fi
  fi

  # Final check for decryption identity if apply/update might need it
  if [[ "$COMMAND" == "apply" || "$COMMAND" == "update" ]]; then
    if [ -z "$INTERNAL_AGE_IDENTITY_FILE" ]; then
        # Check if any .age files exist before warning about missing identity
        if find "$MYCZ_DIR" -name "*.age" -print -quit 2>/dev/null; then
            warning "No explicit identity file found or configured (via MYCZ_AGE_RECIPIENTS with -i, or $DEFAULT_KEY_FILE)."
            warning "Decryption of .age files will rely on 'age' finding a suitable key in its default locations (e.g., ~/.config/age/keys.txt)."
        else
            info "No .age files detected in $MYCZ_DIR, no specific decryption identity needed currently."
        fi
    fi
  fi
  
  # Final check for encryption recipients if add --encrypt is called
  if [[ "$COMMAND" == "add" && "$ENCRYPTED" == "true" && -z "$INTERNAL_AGE_RECIPIENTS" ]]; then
    error "No age recipient could be determined for encryption. Cannot proceed with 'add --encrypt'."
    exit 1
  fi
  success "Age setup check complete."
}

# Function to handle splitting large files before adding to git
handle_large_files_for_add() {
  header "Large File Check & Splitting"
  info "Checking for files larger than $((MYCZ_MAX_FILE_SIZE_BYTES / 1024 / 1024))MB in $MYCZ_DIR..."
  local large_file_found=false
  find "$MYCZ_DIR" -type f -not -path "$MYCZ_DIR/.git/*" -not -path "$MYCZ_DIR/.gitignore" -not -name "*$MYCZ_CHUNK_SUFFIX*" -print0 | while IFS= read -r -d $'\0' file_to_check; do
    local file_size
    file_size=$(stat -c%s "$file_to_check" 2>/dev/null) # Added error suppression for stat

    if [ -n "$file_size" ] && [ "$file_size" -gt "$MYCZ_MAX_FILE_SIZE_BYTES" ]; then
      large_file_found=true
      item "Splitting large file: $(basename "$file_to_check") ($((file_size / 1024 / 1024))MB)"
      local dest_prefix="${file_to_check}${MYCZ_CHUNK_SUFFIX}"
      # Ensure no existing parts with this prefix
      if [[ "$dest_prefix" == *"$MYCZ_CHUNK_SUFFIX" ]]; then
          find "$(dirname "$dest_prefix")" -maxdepth 1 -name "$(basename "$dest_prefix")*" -delete
      fi

      if split -b "$MYCZ_CHUNK_SIZE_SPLIT" "$file_to_check" "$dest_prefix"; then
        sub_item "Successfully split into parts with prefix $(basename "$dest_prefix")"
        rm "$file_to_check" # Remove original large file
        sub_item "Removed original large file: $(basename "$file_to_check")"
      else
        error "Failed to split $file_to_check."
      fi
    fi
  done
  if [ "$large_file_found" = false ]; then
      info "No large files found requiring splitting."
  fi
}

# Function to prepare a temporary source directory for apply/update, reassembling split files
# Returns the path to the prepared directory via echo. Caller must delete it.
prepare_source_for_apply() {
  # echo "DEBUG: prepare_source_for_apply: Entered." >&2 # Keep debug lines commented out for production
  local temp_prepared_dir
  temp_prepared_dir=$(mktemp -d "$MYCZ_DIR/.mycz_apply_prep_XXXXXX")
  local mktemp_exit_status=$?

  if [ "$mktemp_exit_status" -ne 0 ] || [ -z "$temp_prepared_dir" ] || [ ! -d "$temp_prepared_dir" ]; then
    # echo "DEBUG: prepare_source_for_apply: mktemp failed. Dir: '$temp_prepared_dir', Status: $mktemp_exit_status" >&2
    error "Failed to create temporary directory for apply preparation (mktemp status: $mktemp_exit_status, dir: '$temp_prepared_dir')."
    return 1
  fi

  # echo "DEBUG: prepare_source_for_apply: Temp dir created: $temp_prepared_dir" >&2
  info "Preparing source for apply/update in temporary directory..." >&2 # Use info level

  if command -v rsync &> /dev/null; then
    # echo "DEBUG: prepare_source_for_apply: rsync found. Executing rsync." >&2
    sub_item "Copying files using rsync to $temp_prepared_dir..."
    rsync -a --delete \
      --exclude '.git/' \
      --exclude '.gitignore' \
      --exclude "$(basename "$temp_prepared_dir")/" \
      "$MYCZ_DIR/" "$temp_prepared_dir/"
    local rsync_status=$?
    if [ "$rsync_status" -ne 0 ]; then
        # echo "DEBUG: prepare_source_for_apply: rsync failed with status ${rsync_status}." >&2
        error "rsync failed to copy files to temporary directory (exit status ${rsync_status})."
        rm -rf "$temp_prepared_dir"
        return 1
    fi
    # echo "DEBUG: prepare_source_for_apply: rsync completed successfully." >&2
    sub_item "File copy complete."
  else
    # echo "DEBUG: prepare_source_for_apply: rsync not found." >&2
    error "rsync command not found. The script requires rsync for apply/update operations."
    info "Please install rsync (e.g., sudo apt install rsync) and try again."
    rm -rf "$temp_prepared_dir"
    return 1
  fi

  # echo "DEBUG: prepare_source_for_apply: Checking for split files to reassemble in $temp_prepared_dir..." >&2
  sub_item "Checking for split files to reassemble..."
  local reassembly_performed=false
  find "$temp_prepared_dir" -type f -name "*${MYCZ_CHUNK_SUFFIX}aa" -print0 | while IFS= read -r -d $'\0' first_part; do
    reassembly_performed=true
    local base_first_part_name original_file_name parts_prefix reassembled_file_path
    base_first_part_name=$(basename "$first_part")
    original_file_name=${base_first_part_name%${MYCZ_CHUNK_SUFFIX}aa}
    parts_prefix="${original_file_name}${MYCZ_CHUNK_SUFFIX}"
    reassembled_file_path="$(dirname "$first_part")/$original_file_name"

    sub_item "Reassembling: $original_file_name from parts starting with ${parts_prefix}..."
    
    local all_parts_sorted=()
    mapfile -d '' -t all_parts_sorted < <(find "$(dirname "$first_part")" -maxdepth 1 -type f -name "${parts_prefix}*" -print0 | sort -z)

    if [ ${#all_parts_sorted[@]} -gt 0 ]; then
      # Initialize/truncate the reassembled file with the first part
      if cat "${all_parts_sorted[0]}" > "$reassembled_file_path"; then
        local reassembly_ok=true
        # Append subsequent parts if any
        if [ ${#all_parts_sorted[@]} -gt 1 ]; then
            for i in $(seq 1 $((${#all_parts_sorted[@]} - 1)) ); do
                if ! cat "${all_parts_sorted[$i]}" >> "$reassembled_file_path"; then
                    error "Error appending ${all_parts_sorted[$i]} to $reassembled_file_path."
                    reassembly_ok=false
                    break
                fi
            done
        fi

        if [ "$reassembly_ok" = true ]; then
          sub_item "Successfully reassembled $original_file_name"
          # Remove parts after successful reassembly
          for part_to_delete in "${all_parts_sorted[@]}"; do
            rm -f "$part_to_delete"
          done
          sub_item "Removed temporary parts for $original_file_name."
        else
          error "Failed to reassemble $original_file_name. Cleaning up partially reassembled file."
          rm -f "$reassembled_file_path"
        fi
      else
        error "Error writing first part ${all_parts_sorted[0]} to $reassembled_file_path."
      fi
    else
      warning "No parts found for $parts_prefix in $(dirname "$first_part") (unexpected)."
    fi
  done
  # echo "DEBUG: prepare_source_for_apply: File reassembly loop finished." >&2
  if [ "$reassembly_performed" = false ]; then
      sub_item "No split files found requiring reassembly."
  fi

  # echo "DEBUG: prepare_source_for_apply: Success. Will return dir: ${temp_prepared_dir}" >&2
  success "Source preparation complete. Temporary directory: ${temp_prepared_dir}"
  echo "$temp_prepared_dir" # Return the directory path on stdout
  return 0
}

# Function to setup and check git repository
setup_git_repo() {
  header "Git Repository Setup"
  if ! command -v git &> /dev/null; then
    error "git command not found. Please install git."
    exit 1
  fi

  INITIAL_SETUP_PERFORMED=false
  REPO_INITIALLY_EXISTED=true
  TARGET_REMOTE_URL="git@github.com:abraxas678/mycz.git"
  GITIGNORE_FILE="$MYCZ_DIR/.gitignore"
  KEY_FILES_TO_IGNORE=("mycz_age_key.txt" "key.txt" "recipients.txt") # Add common key/recipient file names

  if [ ! -d "$MYCZ_DIR/.git" ]; then
    REPO_INITIALLY_EXISTED=false
    info "Initializing Git repository in $MYCZ_DIR ..."
    if git -C "$MYCZ_DIR" init -q; then
      success "Git repository initialized."
      # Attempt to set default branch to 'main'
      if git -C "$MYCZ_DIR" symbolic-ref HEAD refs/heads/main 2>/dev/null; then
          info "Set default branch to 'main'."
      elif git -C "$MYCZ_DIR" checkout -q -b main 2>/dev/null; then
          info "Created and checked out branch 'main'."
      else
          warning "Could not set default branch to 'main', using git default (likely 'master')."
      fi
      # Initial commit will be done after .gitignore potentially
    else
      error "Failed to initialize Git repository in $MYCZ_DIR."
      exit 1
    fi
  else
      info "Git repository already exists in $MYCZ_DIR."
  fi

  # Setup .gitignore
  gitignore_changed=false
  if [ ! -f "$GITIGNORE_FILE" ]; then
    info "Creating .gitignore file in $MYCZ_DIR ..."
    touch "$GITIGNORE_FILE"
    gitignore_changed=true # Will need to add and commit it
  fi

  for key_file_pattern in "${KEY_FILES_TO_IGNORE[@]}"; do
    if ! grep -qxF -- "$key_file_pattern" "$GITIGNORE_FILE"; then
      info "Adding '$key_file_pattern' to .gitignore ..."
      echo "$key_file_pattern" >> "$GITIGNORE_FILE"
      gitignore_changed=true
    fi
  done

  if [ "$gitignore_changed" = true ] && [ -d "$MYCZ_DIR/.git" ]; then
    info "Staging .gitignore ..."
    git -C "$MYCZ_DIR" add .gitignore
    # Check if there are actual changes staged for .gitignore to avoid empty commit message
    if ! git -C "$MYCZ_DIR" diff --staged --quiet -- .gitignore ; then
        info "Committing .gitignore changes ..."
        if git -C "$MYCZ_DIR" commit -q -m "mycz: Update .gitignore to protect key files"; then
            success ".gitignore committed."
            INITIAL_SETUP_PERFORMED=true # Indicates a setup action that might need a push
        else
            warning "Failed to commit .gitignore changes (maybe no actual changes?)."
        fi
    else
        info ".gitignore already up-to-date."
    fi
  fi 

  if [ "$REPO_INITIALLY_EXISTED" = false ]; then
      # Create initial commit if it's a brand new repo (and .gitignore commit didn't happen or was first)
      # Check if there are any commits. If not, create an initial empty one.
      if ! git -C "$MYCZ_DIR" rev-parse --verify HEAD >/dev/null 2>&1; then
          info "Creating initial empty commit for new repository..."
          if git -C "$MYCZ_DIR" commit -q --allow-empty -m "Initial commit by mycz"; then
              success "Initial empty commit created."
              INITIAL_SETUP_PERFORMED=true
          else
              warning "Failed to create initial empty commit for new repository."
          fi
      fi
  fi

  if ! git -C "$MYCZ_DIR" remote -v | grep -q "^origin"; then
    info "Git remote 'origin' not configured. Setting it to $TARGET_REMOTE_URL ..."
    if git -C "$MYCZ_DIR" remote add origin "$TARGET_REMOTE_URL"; then
      success "Remote 'origin' added: $TARGET_REMOTE_URL"
      INITIAL_SETUP_PERFORMED=true # Mark that setup was done, so we might need to push -u
      
      # Fetch from remote to see if it has content
      info "Fetching from origin..."
      git -C "$MYCZ_DIR" fetch -q origin 2>/dev/null || warning "Initial fetch from origin failed (remote might be empty or inaccessible)."

    else
      error "Failed to add remote 'origin'."
      info "Please check the URL or manually add it:"
      info "  cd $MYCZ_DIR"
      info "  git remote add origin $TARGET_REMOTE_URL"
      exit 1
    fi
  else
    CONFIGURED_REMOTE_URL=$(git -C "$MYCZ_DIR" remote get-url origin)
    if [ "$CONFIGURED_REMOTE_URL" != "$TARGET_REMOTE_URL" ]; then
      warning "Existing remote 'origin' URL ('$CONFIGURED_REMOTE_URL') does not match expected ('$TARGET_REMOTE_URL')."
      info "If this is incorrect, please update it manually:"
      info "  cd $MYCZ_DIR"
      info "  git remote set-url origin $TARGET_REMOTE_URL"
    else
      info "Git remote 'origin' is correctly configured: $TARGET_REMOTE_URL"
    fi
  fi

  # Check if user.name and user.email are set
  if [ -z "$(git -C "$MYCZ_DIR" config user.name)" ] || [ -z "$(git -C "$MYCZ_DIR" config user.email)" ]; then
    warning "Git user.name or user.email not configured for repository $MYCZ_DIR."
    important "Commits might fail or use system default identity."
    important "Please configure them globally or locally. Example (global):"
    important "  git config --global user.name \"Your Name\""
    important "  git config --global user.email \"your.email@example.com\""
  fi

  # If we just initialized the repo or added the remote, attempt to set upstream and push initial commit(s).
  if [ "$INITIAL_SETUP_PERFORMED" = true ]; then
    CURRENT_BRANCH_FOR_SETUP=$(git -C "$MYCZ_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -z "$CURRENT_BRANCH_FOR_SETUP" ] || [ "$CURRENT_BRANCH_FOR_SETUP" = "HEAD" ]; then
        # Determine the branch name (prefer main, then master)
        if git -C "$MYCZ_DIR" show-ref --verify --quiet refs/heads/main; then
            CURRENT_BRANCH_FOR_SETUP="main"
        elif git -C "$MYCZ_DIR" show-ref --verify --quiet refs/heads/master; then
            CURRENT_BRANCH_FOR_SETUP="master"
        else 
            warning "Could not determine local branch for initial push. Assuming 'main'."
            CURRENT_BRANCH_FOR_SETUP="main"
            # Ensure branch exists if we made an assumption
            git -C "$MYCZ_DIR" checkout -q -B "$CURRENT_BRANCH_FOR_SETUP" 
        fi    
    fi
    info "Attempting initial push to set upstream for branch '$CURRENT_BRANCH_FOR_SETUP'..."
    # Check if remote branch already exists
    if git -C "$MYCZ_DIR" ls-remote --quiet --exit-code --heads origin "$CURRENT_BRANCH_FOR_SETUP"; then
        info "Remote branch '$CURRENT_BRANCH_FOR_SETUP' already exists. Pushing without -u."
        important "If local and remote histories have diverged, you may need to pull/rebase first."
        if git -C "$MYCZ_DIR" push -q origin "$CURRENT_BRANCH_FOR_SETUP"; then
            success "Successfully pushed to existing remote branch '$CURRENT_BRANCH_FOR_SETUP'."
        else
            error "Failed to push to existing remote branch '$CURRENT_BRANCH_FOR_SETUP'. Manual intervention may be required (e.g., git pull, resolve conflicts, git push)."
        fi    
    else
        info "Remote branch '$CURRENT_BRANCH_FOR_SETUP' does not exist. Pushing with -u to set upstream."
        if git -C "$MYCZ_DIR" push -q -u origin "$CURRENT_BRANCH_FOR_SETUP"; then
            success "Initial push successful. Upstream for '$CURRENT_BRANCH_FOR_SETUP' is set to 'origin/$CURRENT_BRANCH_FOR_SETUP'."
        else
            error "Failed to perform initial push for '$CURRENT_BRANCH_FOR_SETUP'."
            important "Please ensure the remote repository '$TARGET_REMOTE_URL' is accessible and compatible."
            important "You might need to manually run: git push -u origin $CURRENT_BRANCH_FOR_SETUP"
        fi
    fi
  fi
  success "Git setup check complete."
}

# Helper function for the 'remove' command to process a single item
_handle_remove_item() {
  local item_path_arg="$1"
  local mycz_dir_local="$2"
  local chunk_suffix_local="$3"
  local item_removed_successfully=false

  local target_item_full_path="$mycz_dir_local/$item_path_arg"

  if [ ! -e "$target_item_full_path" ]; then
    warning "Item '$item_path_arg' (resolved to '$target_item_full_path') not found in $mycz_dir_local. Skipping."
    return 1 # Indicate failure
  fi

  if [ -f "$target_item_full_path" ]; then
    local actual_file_basename item_dirname
    actual_file_basename=$(basename "$item_path_arg")
    item_dirname=$(dirname "$target_item_full_path")

    if [[ "$actual_file_basename" == *"$chunk_suffix_local"* ]]; then
      sub_item "Target '$actual_file_basename' is a chunk file. Removing all associated chunks and original file."
      local original_filename_from_chunk
      original_filename_from_chunk=$(echo "$actual_file_basename" | sed -E "s/(.*)${chunk_suffix_local}[a-zA-Z0-9]{2}$/\\1/")
      
      sub_item "Removing chunk parts matching: ${original_filename_from_chunk}${chunk_suffix_local}*"
      find "$item_dirname" -maxdepth 1 -type f -name "${original_filename_from_chunk}${chunk_suffix_local}*" -delete
      
      local original_reassembled_path="$item_dirname/$original_filename_from_chunk"
      if [ -f "$original_reassembled_path" ]; then
        sub_item "Removing original reassembled file: $original_filename_from_chunk"
        rm -f "$original_reassembled_path"
      fi
      item_removed_successfully=true
    else
      sub_item "Removing main file: $item_path_arg"
      if rm -f "$target_item_full_path"; then
        local base_for_chunk_check="$item_path_arg"
        if [[ "$item_path_arg" == *.age ]]; then
          base_for_chunk_check="${item_path_arg%.age}"
        fi
        
        local base_filename_for_chunk_check=$(basename "$base_for_chunk_check")
        if find "$item_dirname" -maxdepth 1 -type f -name "${base_filename_for_chunk_check}${chunk_suffix_local}*" -print -quit 2>/dev/null | grep -q .; then
            sub_item "Also removing associated chunk parts for $base_filename_for_chunk_check"
            find "$item_dirname" -maxdepth 1 -type f -name "${base_filename_for_chunk_check}${chunk_suffix_local}*" -delete
        fi
        item_removed_successfully=true
      else
        error "Failed to remove file '$item_path_arg'."
      fi
    fi
  elif [ -d "$target_item_full_path" ]; then
    sub_item "Removing directory: $item_path_arg"
    if rm -rf "$target_item_full_path"; then
      item_removed_successfully=true
    else
      error "Failed to remove directory '$item_path_arg'."
    fi
  else
    warning "'$item_path_arg' (resolved to '$target_item_full_path') is neither a file nor a directory. Skipping."
    return 1 # Indicate failure
  fi

  if [ "$item_removed_successfully" = true ]; then
    return 0 # Indicate success
  else
    return 1 # Indicate failure
  fi
}

# Helper function for the 'cd' command to interact with copyq
_handle_cd_copyq() {
  local mycz_dir_for_copyq="$1"

  if command -v copyq &>/dev/null; then
    info "Attempting to use copyq to copy and paste the cd command..."
    local cd_command_for_copyq="cd \"$mycz_dir_for_copyq\" && echo && ll.sh && echo"
    if copyq copy "$cd_command_for_copyq"; then
      success "Command '$cd_command_for_copyq' copied to clipboard via copyq."
      if copyq paste; then
        echo # Add a newline before the success message
        success "Executed 'copyq paste'. Check your active window."
      else
        warning "'copyq paste' command failed or did not execute as expected."
      fi
    else
      warning "'copyq copy' command failed. Could not copy to clipboard."
    fi
  else
    info "copyq command not found, skipping clipboard operations."
  fi
}

COMMAND="$1"
shift

AUTO_GIT_PUSH=true # Default to true, can be overridden by a flag later if needed

# Global ENCRYPTED flag, set by 'add' command's argument parsing.
# Initialize to false. It's used by check_age_setup to know if an encryption context is active.
ENCRYPTED=false 

case "$COMMAND" in
  add)
    header "Add Files/Folders"
    add_encrypted_flag=false
    declare -a FILES_TO_PROCESS=()
    declare -a POSITIONAL_ARGS_COLLECTED=()

    while (( "$#" > 0 )); do
        CURRENT_ARG="$1"
        if [ "$CURRENT_ARG" = "--encrypt" ]; then
            add_encrypted_flag=true
            shift 
        elif [[ "$CURRENT_ARG" == -* ]]; then
            warning "Unrecognized option '$CURRENT_ARG' for 'add' command, treating as potential filename."
            POSITIONAL_ARGS_COLLECTED+=("$CURRENT_ARG")
            shift 
        else 
            POSITIONAL_ARGS_COLLECTED+=("$CURRENT_ARG")
            shift
        fi
    done
    FILES_TO_PROCESS=("${POSITIONAL_ARGS_COLLECTED[@]}")
    
    if [ "$add_encrypted_flag" = true ]; then
        ENCRYPTED=true
        info "Encryption enabled for this add operation."
    else
        ENCRYPTED=false
        info "Encryption disabled for this add operation (files will be copied)."
    fi

    if [ ${#FILES_TO_PROCESS[@]} -eq 0 ]; then
      error "No files or folders specified for add command."
      info "Usage: $0 add [--encrypt] <file/folder1> [<file/folder2> ...]"
      exit 1
    fi

    if [ "$ENCRYPTED" = true ]; then
      check_age_setup # Run age setup check if encryption is requested
    fi

    if [ "$AUTO_GIT_PUSH" = true ]; then
      setup_git_repo # Setup git repo before processing files
    fi

    header "Processing Items"
    processed_items_count=0
    total_items_to_process=${#FILES_TO_PROCESS[@]}
    current_item_index=0

    for ITEM_PATH_ARG in "${FILES_TO_PROCESS[@]}"; do
      current_item_index=$((current_item_index + 1))
      info "Processing item $current_item_index/$total_items_to_process: '$ITEM_PATH_ARG'"
      # Use eval carefully for paths with tilde or variables, ensure quoting
      eval "expanded_item_path_arg=$ITEM_PATH_ARG"
      source_abs_path=$(readlink -m "$expanded_item_path_arg" 2>/dev/null) # Suppress readlink errors

      if [ -z "$source_abs_path" ] || [ ! -e "$source_abs_path" ]; then
        error "Source path '$ITEM_PATH_ARG' (resolved to '$expanded_item_path_arg') not found or invalid."
        continue
      fi

      if ! [[ "$source_abs_path" == "$HOME/"* || "$source_abs_path" == "$HOME" ]]; then
        error "Source path '$source_abs_path' is outside the HOME directory. Skipping."
        continue
      fi
      
      # path_in_home is the path relative to $HOME, e.g., .config/foo/bar.txt or .bashrc
      path_in_home="${source_abs_path#$HOME/}"
      if [ "$source_abs_path" == "$HOME" ]; then # Handle adding $HOME itself
          error "Adding the HOME directory ('~') itself is not supported. Please add specific files or subdirectories within HOME."
          continue
      fi
      if [ -z "$path_in_home" ]; then
          error "Could not determine a valid relative path within HOME for '$source_abs_path'. Skipping."
          continue
      fi

      if [ -d "$source_abs_path" ]; then # If the source is a directory
        item "Processing directory: $ITEM_PATH_ARG"
        dir_processed_successfully=false
        # Find all files within this source directory
        while IFS= read -r -d $'\0' individual_file_abs_path; do
          # Determine path relative to the source directory root
          path_of_file_within_added_dir="${individual_file_abs_path#$source_abs_path/}"
          
          # Construct the destination path in .mycz
          dest_file_in_mycz_no_ext="$MYCZ_DIR/$path_in_home/$path_of_file_within_added_dir"
          dest_file_parent_dir=$(dirname "$dest_file_in_mycz_no_ext")
          relative_dest_path_for_msg="$path_in_home/$path_of_file_within_added_dir"

          if ! mkdir -p "$dest_file_parent_dir"; then
            error "Failed to create directory structure '$dest_file_parent_dir' in $MYCZ_DIR for $individual_file_abs_path."
            continue # Skip this file
          fi

          file_basename_for_msg=$(basename "$individual_file_abs_path")

          if [ "$ENCRYPTED" = true ]; then
            dest_final_path_for_file="$dest_file_in_mycz_no_ext.age"
            sub_item "Encrypting '$path_of_file_within_added_dir' -> '$relative_dest_path_for_msg.age'"
            # Read recipients into array to handle spaces/options correctly
            read -r -a age_args <<< "$INTERNAL_AGE_RECIPIENTS"
            if age "${age_args[@]}" -o "$dest_final_path_for_file" "$individual_file_abs_path"; then
              # success "Encrypted $file_basename_for_msg to $dest_final_path_for_file" # Too verbose?
              dir_processed_successfully=true
            else
              error "Failed encrypting file $individual_file_abs_path"
            fi
          else # Not encrypted, copy individual file
            dest_final_path_for_file="$dest_file_in_mycz_no_ext"
            sub_item "Copying    '$path_of_file_within_added_dir' -> '$relative_dest_path_for_msg'"
            if cp "$individual_file_abs_path" "$dest_final_path_for_file"; then
              # success "Copied $file_basename_for_msg to $dest_final_path_for_file" # Too verbose?
              dir_processed_successfully=true
            else
              error "Failed copying file $individual_file_abs_path"
            fi
          fi
        done < <(find "$source_abs_path" -type f -print0)
        find_exit_status=$?
        if [ "$find_exit_status" -ne 0 ]; then
            warning "Potentially issues encountered while finding files within '$source_abs_path'."
        fi

        # Recreate empty directories if any (find -type d -empty)
        while IFS= read -r -d $'\0' empty_dir_abs_path; do
            path_of_empty_dir_within_added_dir="${empty_dir_abs_path#$source_abs_path/}"
            dest_empty_dir_in_mycz="$MYCZ_DIR/$path_in_home/$path_of_empty_dir_within_added_dir"
            if [ -n "$path_of_empty_dir_within_added_dir" ]; then # Ensure it's not the root of the added dir itself
                sub_item "Creating empty directory structure for '$path_of_empty_dir_within_added_dir' in '$MYCZ_DIR/$path_in_home'"
                if mkdir -p "$dest_empty_dir_in_mycz"; then
                    dir_processed_successfully=true # Creating structure counts as success for the dir
                else
                    error "Failed to create empty directory structure '$dest_empty_dir_in_mycz'"
                fi
            fi
        done < <(find "$source_abs_path" -mindepth 1 -type d -empty -print0)
        find_empty_exit_status=$?
         if [ "$find_empty_exit_status" -ne 0 ]; then
             warning "Potentially issues encountered while finding empty directories within '$source_abs_path'."
         fi

        if [ "$dir_processed_successfully" = true ]; then
            processed_items_count=$((processed_items_count + 1)) 
            success "Finished processing directory $ITEM_PATH_ARG."
        else
            warning "Directory $ITEM_PATH_ARG processed, but encountered issues or was empty."
        fi


      elif [ -f "$source_abs_path" ]; then # If the source is a single file
        item "Processing file: $ITEM_PATH_ARG"
        DEST_IN_MYCZ_NO_EXT="$MYCZ_DIR/$path_in_home"
        DEST_PARENT_DIR=$(dirname "$DEST_IN_MYCZ_NO_EXT")
        relative_dest_path_for_msg="$path_in_home"

        if ! mkdir -p "$DEST_PARENT_DIR"; then 
            error "Failed to create directory '$DEST_PARENT_DIR' for $ITEM_PATH_ARG. Skipping."
            continue
        fi
        ITEM_BASENAME_FOR_MSG=$(basename "$source_abs_path")

        if [ "$ENCRYPTED" = true ]; then
          DEST_FINAL_PATH="$DEST_IN_MYCZ_NO_EXT.age"
          sub_item "Encrypting '$ITEM_BASENAME_FOR_MSG' -> '$relative_dest_path_for_msg.age'"
          # Read recipients into array
          read -r -a age_args <<< "$INTERNAL_AGE_RECIPIENTS" 
          if age "${age_args[@]}" -o "$DEST_FINAL_PATH" "$source_abs_path"; then
            success "Encrypted $ITEM_BASENAME_FOR_MSG successfully."
            processed_items_count=$((processed_items_count + 1))
          else
            error "Failed encrypting file $ITEM_PATH_ARG."
          fi
        else # Not encrypted, copy file
          DEST_FINAL_PATH="$DEST_IN_MYCZ_NO_EXT"
          sub_item "Copying    '$ITEM_BASENAME_FOR_MSG' -> '$relative_dest_path_for_msg'"
          if cp "$source_abs_path" "$DEST_FINAL_PATH"; then
            success "Copied $ITEM_BASENAME_FOR_MSG successfully."
            processed_items_count=$((processed_items_count + 1))
          else
            error "Failed copying file $ITEM_PATH_ARG to $DEST_FINAL_PATH."
          fi
        fi
      else
        warning "'$ITEM_PATH_ARG' (resolved to '$source_abs_path') is not a regular file or directory. Skipping."
      fi
    done

    # After processing all items and before git operations, handle large files
    if [ "$processed_items_count" -gt 0 ]; then # Only if items were added/copied to MYCZ_DIR
        handle_large_files_for_add
    fi

    if [ "$AUTO_GIT_PUSH" = true ] && [ "$processed_items_count" -gt 0 ]; then
      header "Git Sync"
      info "Attempting to commit and push changes..."
      # Determine current branch robustly
      CURRENT_BRANCH=$(git -C "$MYCZ_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)
      if [ -z "$CURRENT_BRANCH" ] || [ "$CURRENT_BRANCH" = "HEAD" ]; then 
        # Try getting default remote branch
        REMOTE_DEFAULT_BRANCH=$(git -C "$MYCZ_DIR" remote show origin | grep 'HEAD branch' | cut -d' ' -f5 2>/dev/null)
        if [ -n "$REMOTE_DEFAULT_BRANCH" ] && [ "$REMOTE_DEFAULT_BRANCH" != "(unknown)" ]; then
            CURRENT_BRANCH="$REMOTE_DEFAULT_BRANCH"
            info "Determined remote default branch: $CURRENT_BRANCH"
        # Fallback to local main/master
        elif git -C "$MYCZ_DIR" show-ref --verify --quiet refs/heads/main; then
            CURRENT_BRANCH="main"
            info "Using local branch: main"
        elif git -C "$MYCZ_DIR" show-ref --verify --quiet refs/heads/master; then
            CURRENT_BRANCH="master"
            info "Using local branch: master"
        else
            warning "Could not reliably determine current branch for commit/push. Assuming 'main'."
            CURRENT_BRANCH="main" 
        fi
      else
          info "Using current local branch: $CURRENT_BRANCH"
      fi

      info "Staging all changes..."
      git -C "$MYCZ_DIR" add .
      
      info "Committing changes..."
      commit_msg="mycz: Auto-sync $processed_items_count item(s)"
      # Check if there are staged changes before committing
      if ! git -C "$MYCZ_DIR" diff --staged --quiet; then
          if git -C "$MYCZ_DIR" commit -q -m "$commit_msg"; then
            success "Changes committed: \"$commit_msg\""
            info "Pushing to remote 'origin' (Branch: ${CURRENT_BRANCH})..."
            if git -C "$MYCZ_DIR" push -q origin "HEAD:$CURRENT_BRANCH"; then # Push current HEAD to the determined branch on remote
              success "Changes pushed to origin successfully."
            else
              error "Failed to push changes to origin."
              warning "You might need to set an upstream branch (git push -u origin ${CURRENT_BRANCH})"
              warning "Or resolve conflicts (git pull, resolve, git push) and push manually."
            fi
          else
            error "Commit failed. Check git status in $MYCZ_DIR."
          fi
      else
          info "No changes staged to commit."
      fi
    elif [ "$AUTO_GIT_PUSH" = true ] && [ "$processed_items_count" -eq 0 ]; then
        info "No items were successfully processed, skipping Git commit/push."
    elif [ "$AUTO_GIT_PUSH" = false ]; then
        info "Automatic Git push is disabled."
    fi
    success "Add operation finished."
    ;;

  apply)
    header "Apply Configuration"
    ENCRYPTED=false # Apply doesn't encrypt, but check_age_setup needs context for decryption keys
    check_age_setup

    # echo "DEBUG: apply: Calling prepare_source_for_apply." >&2
    info "Preparing source files (copying, reassembling)..."
    PREPARED_SOURCE_DIR=$(prepare_source_for_apply)
    psfa_exit_status=$?
    # echo "DEBUG: apply: prepare_source_for_apply exited with status ${psfa_exit_status}." >&2
    # echo "DEBUG: apply: PREPARED_SOURCE_DIR variable captured: '${PREPARED_SOURCE_DIR}'." >&2

    # Robust check for prepare_source_for_apply failure
    if [ "${psfa_exit_status}" -ne 0 ] || [ -z "${PREPARED_SOURCE_DIR}" ] || ! echo "${PREPARED_SOURCE_DIR}" | grep -q "^$MYCZ_DIR/.mycz_apply_prep_" || [ ! -d "${PREPARED_SOURCE_DIR}" ]; then
        final_dir_check_failed=false
        if [ "${psfa_exit_status}" -eq 0 ] && [ -n "${PREPARED_SOURCE_DIR}" ] && [ ! -d "${PREPARED_SOURCE_DIR}" ]; then
            final_dir_check_failed=true
            # echo "DEBUG: apply: PREPARED_SOURCE_DIR ('${PREPARED_SOURCE_DIR}') is not a directory, though function returned 0." >&2
        fi

        error "Failed to prepare source directory for apply. Aborting. (psfa_status: ${psfa_exit_status}, dir_val_length: ${#PREPARED_SOURCE_DIR}, final_dir_check_failed: ${final_dir_check_failed})"
        # echo "DEBUG: apply: Content of PREPARED_SOURCE_DIR was: ---start---" >&2
        # echo "${PREPARED_SOURCE_DIR}" >&2
        # echo "---end---" >&2
        
        # Refined cleanup attempt: Only remove if it looks like a valid temp dir path and exists
        if [[ "${PREPARED_SOURCE_DIR}" == "$MYCZ_DIR/.mycz_apply_prep_"* && -d "${PREPARED_SOURCE_DIR}" ]]; then
            info "Attempting cleanup of problematic temporary directory: '${PREPARED_SOURCE_DIR}'."
            rm -rf "${PREPARED_SOURCE_DIR}"
        elif [ "${psfa_exit_status}" -ne 0 ]; then
            info "prepare_source_for_apply failed; assuming it handled its own cleanup."
        fi
        exit 1
    fi

    header "Applying Files to $HOME"
    apply_issues=0
    # Use process substitution here to ensure apply_issues is updated in the current shell
    while IFS= read -r -d $'\0' source_item; do
      relative_path="${source_item#$PREPARED_SOURCE_DIR/}"

      # Skip mycz specific config files if they are at the root of the prepared dir
      if [ "$(dirname "$relative_path")" = "." ]; then 
          if [ "$relative_path" = "mycz_age_key.txt" ] || [ "$relative_path" = "recipients.txt" ]; then
              # info "Skipping mycz config file: $relative_path" # Maybe too verbose
              continue
          fi
      fi

      target_item_path_in_home="$HOME/$relative_path"
      item_basename=$(basename "$source_item")

      if [ -d "$source_item" ]; then
        if [ ! -d "$target_item_path_in_home" ]; then
          sub_item "Creating directory: $relative_path"
          if ! mkdir -p "$target_item_path_in_home"; then
             error "Could not create directory '$target_item_path_in_home'."
             apply_issues=$((apply_issues + 1))
          fi
        fi
        continue # Handled directory creation, move to next item
      fi

      # Ensure target parent directory exists for files
      target_parent_dir=$(dirname "$target_item_path_in_home")
      if [ ! -d "$target_parent_dir" ]; then
          # Try creating parent dir if it doesn't exist
          if ! mkdir -p "$target_parent_dir"; then
              error "Could not create parent directory '$target_parent_dir' for '$relative_path'. Skipping file."
              apply_issues=$((apply_issues + 1))
              continue
          fi
      fi 

      if [[ "$item_basename" == *.age ]]; then 
        decrypted_target_item_path="${target_item_path_in_home%.age}"
        relative_decrypted_target_path="${relative_path%.age}"
        sub_item "Decrypting '$relative_path' -> '$relative_decrypted_target_path'"
        # Prepare age command arguments safely
        age_decrypt_cmd=("age" "-d")
        if [ -n "$INTERNAL_AGE_IDENTITY_FILE" ]; then
          age_decrypt_cmd+=("-i" "$INTERNAL_AGE_IDENTITY_FILE")
        fi
        age_decrypt_cmd+=("-o" "$decrypted_target_item_path" "$source_item")
        # Execute and check status
        if "${age_decrypt_cmd[@]}"; then
          : # No output on success unless needed
        else
          error "Failed to decrypt file '$source_item'."
           apply_issues=$((apply_issues + 1))
        fi
      elif [ -f "$source_item" ]; then 
        sub_item "Copying    '$relative_path' -> '$relative_path'"
        if cp "$source_item" "$target_item_path_in_home"; then
           : # Success, no output
        else
           error "Failed to copy file '$source_item' to '$target_item_path_in_home'."
           apply_issues=$((apply_issues + 1))
        fi
      fi
    done < <(find "$PREPARED_SOURCE_DIR" -mindepth 1 -print0)
    
    if [ -n "$PREPARED_SOURCE_DIR" ] && [ -d "$PREPARED_SOURCE_DIR" ]; then
        info "Cleaning up temporary source directory: $PREPARED_SOURCE_DIR"
        rm -rf "$PREPARED_SOURCE_DIR"
    fi

    if [ "$apply_issues" -eq 0 ]; then
        success "Apply completed successfully."
    else
        warning "Apply completed with $apply_issues issue(s)."
    fi
    ;;

  update)
    header "Update Configuration from Remote"
    ENCRYPTED=false # Update doesn't encrypt, but needs age context for potential apply phase
    setup_git_repo # Ensure git is setup and configured
    
    # Determine current or target branch for pull
    current_branch_for_pull=$(git -C "$MYCZ_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -z "$current_branch_for_pull" ] || [ "$current_branch_for_pull" = "HEAD" ]; then
        remote_default_branch=$(git -C "$MYCZ_DIR" remote show origin | grep 'HEAD branch' | cut -d' ' -f5 2>/dev/null)
        if [ -n "$remote_default_branch" ] && [ "$remote_default_branch" != "(unknown)" ]; then
            current_branch_for_pull="$remote_default_branch"
            info "Using remote default branch for pull: '$remote_default_branch'"
        else 
            # Fallback: check if main exists, else use master
            if git -C "$MYCZ_DIR" show-ref --verify --quiet refs/heads/main; then
                current_branch_for_pull="main"
                info "Could not determine remote default branch, using local 'main'."
            elif git -C "$MYCZ_DIR" show-ref --verify --quiet refs/heads/master; then
                current_branch_for_pull="master"
                info "Could not determine remote default branch, using local 'master'."
            else
                current_branch_for_pull="main" 
                warning "Could not determine any branch, defaulting to 'main'."
            fi
        fi
    else
         info "Attempting pull for current local branch: '$current_branch_for_pull'."
    fi

    info "Pulling changes from remote 'origin' branch '$current_branch_for_pull'..."
    # Use -q for less verbose output on success
    if git -C "$MYCZ_DIR" pull -q origin "$current_branch_for_pull"; then
      success "Successfully pulled changes from remote."
    else
      # Pull might fail for various reasons (conflict, no upstream, network error)
      # Provide more context if possible, but keep it concise.
      warning "Failed to pull changes from remote (check connection, permissions, conflicts)."
      warning "'apply' step will proceed using local files currently in $MYCZ_DIR."
      # Consider adding: git -C "$MYCZ_DIR" status -s # To show potential conflicts briefly
    fi

    info "Proceeding to apply state from local repository ($MYCZ_DIR)..."
    # Set context for check_age_setup and prepare_source_for_apply
    ORIGINAL_COMMAND_FOR_UPDATE_CONTEXT=$COMMAND 
    COMMAND="apply" 
    check_age_setup 
    COMMAND=$ORIGINAL_COMMAND_FOR_UPDATE_CONTEXT # Restore original command context if needed later

    # echo "DEBUG: update: Calling prepare_source_for_apply." >&2
    info "Preparing source files (copying, reassembling)..."
    PREPARED_SOURCE_DIR_FOR_UPDATE=$(prepare_source_for_apply)
    psfa_update_exit_status=$?
    # echo "DEBUG: update: prepare_source_for_apply exited with status ${psfa_update_exit_status}." >&2
    # echo "DEBUG: update: PREPARED_SOURCE_DIR_FOR_UPDATE variable captured: '${PREPARED_SOURCE_DIR_FOR_UPDATE}'." >&2

    # Robust check identical to the 'apply' command's check
    if [ "${psfa_update_exit_status}" -ne 0 ] || [ -z "${PREPARED_SOURCE_DIR_FOR_UPDATE}" ] || ! echo "${PREPARED_SOURCE_DIR_FOR_UPDATE}" | grep -q "^$MYCZ_DIR/.mycz_apply_prep_" || [ ! -d "${PREPARED_SOURCE_DIR_FOR_UPDATE}" ]; then
        final_dir_check_failed_update=false
        if [ "${psfa_update_exit_status}" -eq 0 ] && [ -n "${PREPARED_SOURCE_DIR_FOR_UPDATE}" ] && [ ! -d "${PREPARED_SOURCE_DIR_FOR_UPDATE}" ]; then
            final_dir_check_failed_update=true
            # echo "DEBUG: update: PREPARED_SOURCE_DIR_FOR_UPDATE ('${PREPARED_SOURCE_DIR_FOR_UPDATE}') is not a directory, though function returned 0." >&2
        fi

        error "Failed to prepare source directory for update's apply phase. Aborting. (psfa_status: ${psfa_update_exit_status}, dir_val_length: ${#PREPARED_SOURCE_DIR_FOR_UPDATE}, final_dir_check_failed: ${final_dir_check_failed_update})"
        # echo "DEBUG: update: Content of PREPARED_SOURCE_DIR_FOR_UPDATE was: ---start---" >&2
        # echo "${PREPARED_SOURCE_DIR_FOR_UPDATE}" >&2
        # echo "---end---" >&2

        if [[ "${PREPARED_SOURCE_DIR_FOR_UPDATE}" == "$MYCZ_DIR/.mycz_apply_prep_"* && -d "${PREPARED_SOURCE_DIR_FOR_UPDATE}" ]]; then
            info "Attempting cleanup of problematic temporary directory: '${PREPARED_SOURCE_DIR_FOR_UPDATE}'." >&2
            rm -rf "${PREPARED_SOURCE_DIR_FOR_UPDATE}"
        elif [ "${psfa_update_exit_status}" -ne 0 ]; then
            info "prepare_source_for_apply failed; assuming it handled its own cleanup."
        fi
        exit 1
    fi

    header "Applying Updated Files to $HOME"
    apply_update_issues=0
    # Use process substitution here to ensure apply_update_issues is updated in the current shell
    while IFS= read -r -d $'\0' source_item; do
      relative_path="${source_item#$PREPARED_SOURCE_DIR_FOR_UPDATE/}"
      # Skip mycz internal config files
      if [ "$(dirname "$relative_path")" = "." ]; then 
          if [[ "$relative_path" == "mycz_age_key.txt" || "$relative_path" == "recipients.txt" ]]; then
              continue
          fi
      fi
      target_item_path_in_home="$HOME/$relative_path"
      item_basename=$(basename "$source_item")

      if [ -d "$source_item" ]; then 
        if [ ! -d "$target_item_path_in_home" ]; then
          sub_item "Creating directory: $relative_path"
          if ! mkdir -p "$target_item_path_in_home"; then
             error "Could not create directory '$target_item_path_in_home'."
             apply_update_issues=$((apply_update_issues + 1))
          fi
        fi
        continue
      fi

      target_parent_dir=$(dirname "$target_item_path_in_home")
      if [ ! -d "$target_parent_dir" ]; then 
        if ! mkdir -p "$target_parent_dir"; then
            error "Could not create parent directory '$target_parent_dir' for '$relative_path'. Skipping file."
            apply_update_issues=$((apply_update_issues + 1))
            continue
        fi
      fi 

      if [[ "$item_basename" == *.age ]]; then 
        decrypted_target_item_path="${target_item_path_in_home%.age}"
        relative_decrypted_target_path="${relative_path%.age}"
        sub_item "Decrypting '$relative_path' -> '$relative_decrypted_target_path'"
        age_decrypt_cmd=("age" "-d")
        if [ -n "$INTERNAL_AGE_IDENTITY_FILE" ]; then 
          age_decrypt_cmd+=("-i" "$INTERNAL_AGE_IDENTITY_FILE")
        fi
        age_decrypt_cmd+=("-o" "$decrypted_target_item_path" "$source_item")
        if "${age_decrypt_cmd[@]}"; then
          : # Success, no output
        else
          error "Failed to decrypt file '$source_item'."
           apply_update_issues=$((apply_update_issues + 1))
        fi
      elif [ -f "$source_item" ]; then 
        sub_item "Copying    '$relative_path' -> '$relative_path'"
        if cp "$source_item" "$target_item_path_in_home"; then
           : # Success, no output
        else
           error "Failed to copy file '$source_item' to '$target_item_path_in_home'."
           apply_update_issues=$((apply_update_issues + 1))
        fi
      fi
    done < <(find "$PREPARED_SOURCE_DIR_FOR_UPDATE" -mindepth 1 -print0)

    if [ -n "$PREPARED_SOURCE_DIR_FOR_UPDATE" ] && [ -d "$PREPARED_SOURCE_DIR_FOR_UPDATE" ]; then
        info "Cleaning up temporary source directory: $PREPARED_SOURCE_DIR_FOR_UPDATE"
        rm -rf "$PREPARED_SOURCE_DIR_FOR_UPDATE"
    fi

    if [ "$apply_update_issues" -eq 0 ]; then
        success "Update (pull and apply) completed successfully."
    else
        warning "Update completed, but the apply phase encountered $apply_update_issues issue(s)."
    fi
    ;;

  list)
    header "List Managed Files/Folders in $MYCZ_DIR"
    if [ ! -d "$MYCZ_DIR" ] || [ -z "$(ls -A "$MYCZ_DIR")" ]; then
      info "MYCZ_DIR ($MYCZ_DIR) is empty or does not exist."
      exit 0
    fi

    # Using find to list items, excluding .git, .gitignore, and temp/chunk files
    # We want to show the paths relative to MYCZ_DIR
    # -mindepth 1 ensures we don't list MYCZ_DIR itself
    # -path exclusions should be relative to the find starting point ($MYCZ_DIR)
    # -printf "%P\\n" prints the path relative to the starting point
    
    info "Files and folders managed by mycz (relative to $MYCZ_DIR):"
    
    # Store find output in a variable to check if it's empty
    # Use process substitution and mapfile for safer handling of filenames
    declare -a managed_files
    mapfile -t managed_files < <(find "$MYCZ_DIR" -mindepth 1 \
                                     \( -path "$MYCZ_DIR/.git" -o -path "$MYCZ_DIR/.gitignore" -o -path "$MYCZ_DIR/.mycz_apply_prep_*" -o -name "*$MYCZ_CHUNK_SUFFIX*" -o -path "$MYCZ_DIR/mycz_age_key.txt" \) -prune \
                                     -o -printf "%P\n" | sort)
    
    if [ ${#managed_files[@]} -eq 0 ]; then
        info "No user-managed files or folders found (excluding .git, .gitignore, and temporary files)."
    else
        for item_path in "${managed_files[@]}"; do
            if [ -d "$MYCZ_DIR/$item_path" ]; then
                item "[D] $item_path" # Indicate directory
            else
                item "[F] $item_path" # Indicate file
            fi
        done
    fi
    success "List operation finished."
    ;;

  remove)
    header "Remove Files/Folders from mycz"
    if [ $# -eq 0 ]; then
      error "No files or folders specified for remove command."
      info "Usage: $0 remove <path_in_mycz1> [<path_in_mycz2> ...]"
      exit 1
    fi

    if [ "$AUTO_GIT_PUSH" = true ]; then
      setup_git_repo # Ensure git is setup
    fi

    declare -a ITEMS_TO_REMOVE=("$@") # Capture all arguments
    processed_remove_count=0
    total_items_to_remove=${#ITEMS_TO_REMOVE[@]}
    current_item_index=0

    for ITEM_PATH_ARG in "${ITEMS_TO_REMOVE[@]}"; do
      current_item_index=$((current_item_index + 1))
      info "Processing removal target $current_item_index/$total_items_to_remove: '$ITEM_PATH_ARG'"

      # Call the helper function
      if _handle_remove_item "$ITEM_PATH_ARG" "$MYCZ_DIR" "$MYCZ_CHUNK_SUFFIX"; then
          processed_remove_count=$((processed_remove_count + 1))
          success "Successfully processed removal for '$ITEM_PATH_ARG'."
      else 
          # Error/warning messages are handled within the helper function
          : # No additional message needed here, or a generic "failed to process" if desired
      fi
    done

    # After processing all items for removal
    if [ "$AUTO_GIT_PUSH" = true ] && [ "$processed_remove_count" -gt 0 ]; then
      header "Git Sync for Removals"
      info "Attempting to commit and push changes..."
      CURRENT_BRANCH=$(git -C "$MYCZ_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)
      if [ -z "$CURRENT_BRANCH" ] || [ "$CURRENT_BRANCH" = "HEAD" ]; then 
        REMOTE_DEFAULT_BRANCH=$(git -C "$MYCZ_DIR" remote show origin | grep 'HEAD branch' | cut -d' ' -f5 2>/dev/null)
        if [ -n "$REMOTE_DEFAULT_BRANCH" ] && [ "$REMOTE_DEFAULT_BRANCH" != "(unknown)" ]; then
            CURRENT_BRANCH="$REMOTE_DEFAULT_BRANCH"
            info "Determined remote default branch for commit: $CURRENT_BRANCH"
        elif git -C "$MYCZ_DIR" show-ref --verify --quiet refs/heads/main; then
            CURRENT_BRANCH="main"
            info "Using local branch 'main' for commit."
        elif git -C "$MYCZ_DIR" show-ref --verify --quiet refs/heads/master; then
            CURRENT_BRANCH="master"
            info "Using local branch 'master' for commit."
        else
            warning "Could not reliably determine current branch for commit. Assuming 'main'."
            CURRENT_BRANCH="main" 
        fi
      else
          info "Using current local branch for commit: $CURRENT_BRANCH"
      fi

      info "Staging all changes (including deletions)..."
      git -C "$MYCZ_DIR" add . 
      
      info "Committing changes..."
      commit_msg="mycz: Remove $processed_remove_count item(s)"
      if ! git -C "$MYCZ_DIR" diff --staged --quiet; then
          if git -C "$MYCZ_DIR" commit -q -m "$commit_msg"; then
            success "Changes committed: \"$commit_msg\""
            info "Pushing to remote 'origin' (Branch: ${CURRENT_BRANCH})..."
            if git -C "$MYCZ_DIR" push -q origin "HEAD:$CURRENT_BRANCH"; then
              success "Changes pushed to origin successfully."
            else
              error "Failed to push changes to origin."
              warning "You might need to set an upstream branch (git push -u origin ${CURRENT_BRANCH})"
              warning "Or resolve conflicts (git pull, resolve, git push) and push manually."
            fi
          else
            error "Commit failed. Check git status in $MYCZ_DIR."
          fi
      else
          info "No changes staged to commit (unexpected after successful removals). Review $MYCZ_DIR."
      fi
    elif [ "$AUTO_GIT_PUSH" = true ] && [ "$processed_remove_count" -eq 0 ]; then
        info "No items were successfully removed or no items to remove, skipping Git commit/push."
    elif [ "$AUTO_GIT_PUSH" = false ]; then
        info "Automatic Git push is disabled."
    fi
    success "Remove operation finished."
    ;;

  cd)
    header "Change to mycz Directory"
    # MYCZ_DIR is defined globally, and mkdir -p is called at the script start.
    info "This command helps you navigate to the MYCZ directory ($MYCZ_DIR)."
    info "To change your current shell's directory, please execute the output of this command by running:"
    info "  eval \"\$($0 cd)\""
    
    # Print the actual cd command to stdout for eval to capture and execute.
    # Ensures the path is quoted in the output cd command.
    printf "cd \"%s\"\n" "$MYCZ_DIR"

    # Call helper to handle copyq interaction
    _handle_cd_copyq "$MYCZ_DIR"
    ;;

  init)
    header "Initialize mycz Environment"
    info "Ensuring MYCZ_DIR ($MYCZ_DIR) exists..."
    mkdir -p "$MYCZ_DIR" # Ensure it exists, though usually done at script start
    success "MYCZ_DIR verified."

    header "GitHub CLI (gh) Setup"
    if ! command -v gh &> /dev/null; then
      error "GitHub CLI (gh) not found. It is required for seamless repository interaction."
      info "Please install it based on your operating system:"
      info "  Debian/Ubuntu: sudo apt update && sudo apt install gh"
      info "  Fedora/RHEL:   sudo dnf install gh"
      info "  macOS (Homebrew): brew install gh"
      info "  Windows (winget): winget install GitHub.cli"
      info "  Other:         https://github.com/cli/cli#installation"
      important "After installing gh, please re-run: mycz.sh init"
      exit 1
    else
      success "GitHub CLI (gh) is installed."
    fi

    info "Checking GitHub authentication status..."
    if ! gh auth status &> /dev/null; then
      warning "You are not logged into GitHub CLI."
      important "Please run 'gh auth login' to authenticate with GitHub."
      info "After successful authentication with 'gh auth login', you might need to re-run 'mycz.sh init' or specific commands that interact with the remote."
      # Optionally, you could exit here or make subsequent git operations conditional
    else
      success "GitHub CLI is authenticated."
    fi

    info "Setting global Git user configuration..."
    
    current_email=$(git config --global user.email)
    current_name=$(git config --global user.name)

    target_email="abraxas678@gmail.com"
    target_name="abraxas678"

    if [ "$current_email" == "$target_email" ]; then
        info "Global git user.email is already set to '$target_email'."
    else
        if git config --global user.email "$target_email"; then
            success "Global git user.email set to '$target_email'."
        else
            error "Failed to set global git user.email."
        fi
    fi

    if [ "$current_name" == "$target_name" ]; then
        info "Global git user.name is already set to '$target_name'."
    else
        if git config --global user.name "$target_name"; then
            success "Global git user.name set to '$target_name'."
        else
            error "Failed to set global git user.name."
        fi
    fi
    
    success "Initialization complete."
    ;;

  help|--help|-h)
    header "mycz - Manage Your Configuration Zone"
    info "Usage: $0 <command> [options] [arguments...]"
    echo "" # Use echo for plain spacing
    info "${COLOR_BOLD}Commands:${COLOR_RESET}"
    printf "  %-20s %s\\n" "add [--encrypt] ..." "Add file(s)/folder(s) from HOME to the repo."
    printf "  %-20s %s\\n" "" "Copies by default. Use --encrypt to encrypt with age."
    printf "  %-20s %s\\n" "apply" "Apply configuration from the repo back to HOME."
    printf "  %-20s %s\\n" "" "Decrypts .age files if necessary."
    printf "  %-20s %s\\n" "update" "Pull changes from remote Git repo, then run 'apply'."
    printf "  %-20s %s\\n" "list" "List all files and folders managed in the $MYCZ_DIR."
    printf "  %-20s %s\\n" "remove <path...>" "Remove file(s)/folder(s) from mycz management."
    printf "  %-20s %s\\n" "" "(Does NOT delete original files from HOME)."
    printf "  %-20s %s\\n" "cd" "Output command to change to the MYCZ_DIR (use with eval)."
    printf "  %-20s %s\\n" "init" "Initialize mycz environment (e.g., set git global config)."
    printf "  %-20s %s\\n" "help" "Show this help message."
    echo ""
    info "${COLOR_BOLD}Environment Variables:${COLOR_RESET}"
    printf "  %-30s %s\\n" "MYCZ_AGE_RECIPIENTS" "Age recipient flags (e.g., '-r age1...'). Overrides default key."
    printf "  %-30s %s\\n" "" "Can include '-i /path/to/key' for decryption identity."
    printf "  %-30s %s\\n" "MYCZ_DIR" "Directory for the repository (Default: \$HOME/.mycz)."
    echo ""
    info "${COLOR_BOLD}Configuration Files:${COLOR_RESET}"
    printf "  %-30s %s\\n" "\$HOME/.mycz/mycz_age_key.txt" "Default age private key (used if MYCZ_AGE_RECIPIENTS not set)."
    printf "  %-30s %s\\n" "\$HOME/.mycz/.gitignore" "Specifies files/patterns to ignore in the repo."
    echo ""
    info "Repository is stored in: $MYCZ_DIR"
    info "Remote target: $TARGET_REMOTE_URL (can be changed in setup_git_repo function)"
    ;;

  *)
    error "Unknown command: '$COMMAND'"
    info "Run '$0 help' for usage information."
    exit 1
    ;;
esac

echo