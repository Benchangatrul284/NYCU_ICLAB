cd ../01_RTL

while true; do
    # Run the command and capture its output
    python3 ../00_TESTBED/gen_seed.py
    python3 ../00_TESTBED/pic_generation.py
    output=$(./01_run_vcs_rtl | tee /dev/tty)
    
    # Print the output for reference (optional because it will already be displayed)
    echo "$output"
    
    # Check if the output contains "ERROR" or "FAIL"
    if echo "$output" | grep -q -E "FAIL"; then
        echo "Error detected. Exiting."
        break
    fi

    # Add a delay (optional) to prevent too frequent execution
    sleep 1
done
