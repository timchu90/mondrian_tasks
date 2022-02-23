version 1.0

task Genotyper{
    input{
        File bam
        File bai
        File vcf_file
        File vcf_file_idx
        Array[String] intervals
        String filename_prefix = "snv_genotyping"
        String? singularity_image
        String? docker_image
        Int? num_threads = 8
        Int? memory_gb = 12
        Int? walltime_hours = 24
    }
    command<<<
        for interval in ~{sep=" "intervals}
            do
                echo "snv_genotyping_utils snv_genotyper --interval ${interval} --bam ~{bam} \
                 --targets_vcf ~{vcf_file}  --output ${interval}.genotype.csv.gz" >> commands.txt
            done
        parallel --jobs ~{num_threads} < commands.txt

        inputs=`echo *genotype.csv.gz | sed "s/ / --in_f /g"`
        csverve concat --in_f $inputs  --out_f ~{filename_prefix}.csv.gz --write_header
    >>>
    output{
        File output_csv = "~{filename_prefix}.csv.gz"
        File output_yaml = "~{filename_prefix}.csv.gz.yaml"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task SnvGenotypingMetadata{
    input{
        File output_csv
        File output_csv_yaml
        File vartrix_output_csv
        File vartrix_output_csv_yaml
        File metadata_input
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 48
    }
    command<<<
        snv_genotyping_utils generate_metadata \
        --outputs ~{output_csv} ~{output_csv_yaml} \
        --vartrix_outputs ~{vartrix_output_csv} ~{vartrix_output_csv_yaml} \
        --metadata_input ~{metadata_input} \
        --metadata_output metadata.yaml
    >>>
    output{
        File metadata_output = "metadata.yaml"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task GenerateCellBarcodes{
    input{
        File bamfile
        File baifile
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 48
    }
    command<<<
        snv_genotyping_utils generate_cell_barcodes --bam ~{bamfile} --output barcodes.txt
    >>>
    output{
        File cell_barcodes = "barcodes.txt"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

task RunVartrix{
    input{
        File bamfile
        File baifile
        File fasta
        File fasta_fai
        File vcf_file
        File cell_barcodes
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 48
    }
    command<<<
        vartrix_linux --bam ~{bamfile} \
        --fasta ~{fasta} --vcf ~{vcf_file} \
         --cell-barcodes ~{cell_barcodes} \
        --scoring-method coverage \
        --out-barcodes out_snv_barcodes.txt \
        --out-matrix out_snv_matrix.mtx \
        --out-variants out_snv_variants.txt \
        --ref-matrix out_snv_ref.txt \
        --mapq 20 \
        --no-duplicates \
        --primary-alignments
    >>>
    output{
        File out_barcodes = "out_snv_barcodes.txt"
        File out_variants = "out_snv_variants.txt"
        File ref_counts = "out_snv_ref.txt"
        File alt_counts = "out_snv_matrix.mtx"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task ParseVartrix{
    input{
        File barcodes
        File variants
        File ref_counts
        File alt_counts
        String? singularity_image
        String? docker_image
        Int? memory_gb = 8
        Int? walltime_hours = 8
    }
    command<<<
        snv_genotyping_utils parse_vartrix \
        --barcodes ~{barcodes} \
        --variants ~{variants} \
        --ref_counts ~{ref_counts} \
        --alt_counts ~{alt_counts} \
        --outfile vartrix_parsed.csv.gz
    >>>
    output{
        File outfile = "vartrix_parsed.csv.gz"
        File outfile_yaml = "vartrix_parsed.csv.gz.yaml"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}
