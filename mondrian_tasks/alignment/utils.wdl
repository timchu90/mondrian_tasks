version 1.0


task TagBamWithCellid{
    input {
        File infile
        String cell_id
        String? singularity_dir
    }
    command <<<
        alignment_utils tag_bam_with_cellid --infile ~{infile} --outfile outfile.bam --cell_id ~{cell_id}
    >>>
    output{
        File outfile = "outfile.bam"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: 'quay.io/mondrianscwgs/alignment:v0.0.5'
        singularity: '~{singularity_dir}/alignment_v0.0.5.sif'
    }

}


task bamMerge{
    input{
        Array[File] input_bams
        Array[String] cell_ids
        File metrics
        File metrics_yaml
        String? singularity_dir
        Int ncores
        String filename_prefix
    }
    command <<<
        alignment_utils merge_cells --metrics ~{metrics}  --infile ~{sep=" "input_bams} --cell_id ~{sep=" "cell_ids} \
        --tempdir temp --ncores ~{ncores} --contaminated_outfile ~{filename_prefix}_contaminated.bam \
        --control_outfile ~{filename_prefix}_control.bam \
        --pass_outfile ~{filename_prefix}.bam
    >>>
    output{
        File pass_outfile = "~{filename_prefix}.bam"
        File pass_outfile_bai = "~{filename_prefix}.bam.bai"
        File contaminated_outfile = "~{filename_prefix}.bam"
        File contaminated_outfile_bai = "~{filename_prefix}.bam.bai"
        File control_outfile = "~{filename_prefix}.bam"
        File control_outfile_bai = "~{filename_prefix}.bam.bai"
    }
    runtime{
        memory: "12 GB"
        cpu: ncores
        walltime: "96:00"
        docker: 'quay.io/mondrianscwgs/alignment:v0.0.5'
        singularity: '~{singularity_dir}/alignment_v0.0.5.sif'
        disks: "local-disk " + length(input_bams) + " HDD"
    }
}


task AddContaminationStatus{
    input{
        File input_csv
        File input_yaml
        String? singularity_dir
    }
    command<<<
        alignment_utils add_contamination_status --infile ~{input_csv} --outfile output.csv.gz
    >>>
    output{
        File output_csv = "output.csv.gz"
        File output_yaml = "output.csv.gz.yaml"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: 'quay.io/mondrianscwgs/alignment:v0.0.5'
        singularity: '~{singularity_dir}/alignment_v0.0.5.sif'
    }
}

task ClassifyFastqscreen{
    input{
        File training_data
        File metrics
        File metrics_yaml
        String? singularity_dir
        String filename_prefix
    }
    command<<<
        alignment_utils classify_fastqscreen --training_data ~{training_data} --metrics ~{metrics} --output ~{filename_prefix}.csv.gz
    >>>
    output{
        File output_csv = "~{filename_prefix}.csv.gz"
        File output_yaml = "~{filename_prefix}.csv.gz.yaml"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: 'quay.io/mondrianscwgs/alignment:v0.0.5'
        singularity: '~{singularity_dir}/alignment_v0.0.5.sif'
    }
}
