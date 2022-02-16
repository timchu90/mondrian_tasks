version 1.0

struct Lane{
    File fastq1
    File fastq2
    String lane_id
    String flowcell_id
}

task AlignPostprocessAllLanes{
    input {
        Array[Lane] fastq_files
        File metadata_yaml
        File human_reference
        File human_reference_fa_fai
        File human_reference_fa_amb
        File human_reference_fa_ann
        File human_reference_fa_bwt
        File human_reference_fa_pac
        File human_reference_fa_sa
        File mouse_reference
        File mouse_reference_fa_fai
        File mouse_reference_fa_amb
        File mouse_reference_fa_ann
        File mouse_reference_fa_bwt
        File mouse_reference_fa_pac
        File mouse_reference_fa_sa
        File salmon_reference
        File salmon_reference_fa_fai
        File salmon_reference_fa_amb
        File salmon_reference_fa_ann
        File salmon_reference_fa_bwt
        File salmon_reference_fa_pac
        File salmon_reference_fa_sa
        String cell_id
        String adapter1 = "CTGTCTCTTATACACATCTCCGAGCCCACGAGAC"
        String adapter2 = "CTGTCTCTTATACACATCTGACGCTGCCGACGA"
        Int min_mqual=20
        Int min_bqual=20
        Boolean count_unpaired=false
        String? singularity_image
        String? docker_image
    }
    command {
        alignment_utils alignment \
        --fastq_files ~{write_json(fastq_files)} \
        --metadata_yaml ~{metadata_yaml} \
        --human_reference ~{human_reference} \
        --mouse_reference ~{mouse_reference} \
        --salmon_reference ~{salmon_reference} \
        --tempdir tempdir \
        --adapter1 ~{adapter1} \
        --adapter2 ~{adapter2} \
        --cell_id ~{cell_id} \
        --wgs_metrics_mqual ~{min_mqual} \
        --wgs_metrics_bqual ~{min_bqual} \
        --wgs_metrics_count_unpaired ~{count_unpaired} \
        --bam_output aligned.bam \
        --metrics_output metrics.csv.gz \
        --metrics_gc_output gc_metrics.csv.gz \
        --fastqscreen_detailed_output detailed_fastqscreen.csv.gz \
        --fastqscreen_summary_output summary_fastqscreen.csv.gz \
        --tar_output ~{cell_id}.tar.gz
    }
    output {
        File bam = "aligned.bam"
        File bai = "aligned.bam.bai"
        File metrics = "metrics.csv.gz"
        File metrics_yaml = "metrics.csv.gz.yaml"
        File gc_metrics = "gc_metrics.csv.gz"
        File gc_metrics_yaml = "gc_metrics.csv.gz.yaml"
        File fastqscreen_detailed_metrics = "detailed_fastqscreen.csv.gz"
        File fastqscreen_detailed_metrics_yaml = "detailed_fastqscreen.csv.gz.yaml"
        File fastqscreen_summary_metrics = "summary_fastqscreen.csv.gz"
        File fastqscreen_summary_metrics_yaml = "summary_fastqscreen.csv.gz.yaml"
        File tar_output = "~{cell_id}.tar.gz"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "24:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task TrimGalore{
    input {
        File r1
        File r2
        String adapter1
        String adapter2
        String? singularity_image
        String? docker_image

    }
    command <<<
        alignment_utils trim_galore --r1 ~{r1} --r2 ~{r2} \
        --output_r1 trimmed_r1.fastq.gz --output_r2 trimmed_r2.fastq.gz \
        --adapter1 ~{adapter1} --adapter2 ~{adapter2} --tempdir tempdir
    >>>
    output{
        File output_r1 = "trimmed_r1.fastq.gz"
        File output_r2 = "trimmed_r2.fastq.gz"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task TagBamWithCellid{
    input {
        File infile
        String cell_id
        String? singularity_image
        String? docker_image

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
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }

}


task BamMerge{
    input{
        Array[File] input_bams
        Array[String] cell_ids
        File metrics
        File metrics_yaml
        String? singularity_image
        String? docker_image

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
        File contaminated_outfile = "~{filename_prefix}_contaminated.bam"
        File contaminated_outfile_bai = "~{filename_prefix}_contaminated.bam.bai"
        File control_outfile = "~{filename_prefix}_control.bam"
        File control_outfile_bai = "~{filename_prefix}_control.bam.bai"
    }
    runtime{
        memory: 12 * ncores + "GB"
        cpu: ncores
        walltime: "96:00"
        disks: if length(input_bams) > 3000 then "local-disk 5999 LOCAL" else if length(input_bams) > 1500 then "local-disk 2999 LOCAL" else if length(input_bams) > 750 then "local-disk 1499 LOCAL" else "local-disk 749 LOCAL"        
        preemptible: 0
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task AddContaminationStatus{
    input{
        File input_csv
        File input_yaml
        String reference_genome
        String? singularity_image
        String? docker_image

    }
    command<<<
        alignment_utils add_contamination_status --infile ~{input_csv} --outfile output.csv.gz \
        --reference ~{reference_genome}
    >>>
    output{
        File output_csv = "output.csv.gz"
        File output_yaml = "output.csv.gz.yaml"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

task ClassifyFastqscreen{
    input{
        File training_data
        File metrics
        File metrics_yaml
        String? singularity_image
        String? docker_image

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
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

task AlignmentMetadata{
    input{
        File bam
        File bai
        File contaminated_bam
        File contaminated_bai
        File control_bam
        File control_bai
        File metrics
        File metrics_yaml
        File gc_metrics
        File gc_metrics_yaml
        File fastqscreen_detailed
        File fastqscreen_detailed_yaml
        File tarfile
        File metadata_input
        String? singularity_image
        String? docker_image

    }
    command<<<
        alignment_utils generate_metadata \
        --bam ~{bam} ~{bai} \
        --control ~{control_bam} ~{control_bai} \
        --contaminated ~{contaminated_bam} ~{contaminated_bai} \
        --metrics ~{metrics} ~{metrics_yaml} \
        --gc_metrics ~{gc_metrics} ~{gc_metrics_yaml} \
        --fastqscreen_detailed ~{fastqscreen_detailed} ~{fastqscreen_detailed_yaml} \
        --tarfile ~{tarfile} --metadata_output metadata.yaml --metadata_input ~{metadata_input}
    >>>
    output{
        File metadata_output = "metadata.yaml"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}
