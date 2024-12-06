bcftools query -f '%CHROM\t%POS\n' Spis_noreplicates_badsamples_nofilters_linked.vcf > vcf_positions.txt

# Sort file
sort -k1,1 -k2,2n vcf_positions.txt > vcf_positions_sorted.txt

# Input file
input_file="vcf_positions_sorted.txt"

# Output file
output_file="snp_windows.txt"

# Initialize variables
current_scaffold=""
window_id=0
window_start=0
window_end=9999  # Initialize for the first 10kb window

# Check if input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Input file not found!"
    exit 1
fi

# Output the header
echo -e "snp_id\twin_id" > "$output_file"

# Read the input file line by line
while read -r scaffold position; do
    # Check if the scaffold has changed
    if [[ "$scaffold" != "$current_scaffold" ]]; then
        # Move to the next scaffold
        current_scaffold="$scaffold"
        
        # Increment window_id since we've moved to a new scaffold
        window_id=$((window_id + 1))
        window_start=0
        window_end=9999

        # Check if the length of the current scaffold is less than 10kb
        scaffold_length=$(awk -v scaffold="$scaffold" '$1 == scaffold {length += $2} END {print length}' "$input_file")

        if [[ "$scaffold_length" -lt 10000 ]]; then
            # If the scaffold is less than 10kb, assign it to the current window_id
            echo -e "${scaffold}:${position}\twind_${window_id}" >> "$output_file"
        fi
    fi

    # Check if the position fits in the current window
    if [[ "$position" -gt "$window_end" ]]; then
        # Move to the next window
        window_id=$((window_id + 1))
        window_start=$((window_start + 10000))
        window_end=$((window_end + 10000))
    fi

    # Assign SNP to the current window
    echo -e "${scaffold}:${position}\twind_${window_id}" >> "$output_file"
done < "$input_file"
