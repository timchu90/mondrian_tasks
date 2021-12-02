version 1.0

task CollectMetrics{
    input{
        File wgs_metrics
        File insert_metrics
        File flagstat
        File markdups_metrics
        String cell_id
        File coverage_metrics
        File coverage_metrics_yaml
        String? singularity_dir
    }
    command<<<
        alignment_utils collect_metrics \
        --wgs_metrics ~{wgs_metrics} \
        --insert_metrics ~{insert_metrics} \
        --flagstat ~{flagstat} \
        --markdups_metrics ~{markdups_metrics} \
        --cell_id ~{cell_id} \
        --coverage_metrics ~{coverage_metrics} \
        --output output.csv.gz \
    >>>
    output{
        File output_csv = "output.csv.gz"
        File output_csv_yaml = "output.csv.gz.yaml"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: 'us.gcr.io/nygc-dlp-s-c0c0/alignment:v0.0.7'
        singularity: '~{singularity_dir}/alignment_v0.0.7.sif'
    }
}


task CollectGcMetrics{
    input{
        File infile
        String cell_id
        String? singularity_dir
    }
    command<<<
        alignment_utils collect_gc_metrics \
        --infile ~{infile} \
        --cell_id ~{cell_id} \
        --outfile output.csv.gz
    >>>
    output{
        File output_csv = "output.csv.gz"
        File output_csv_yaml = "output.csv.gz.yaml"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: 'us.gcr.io/nygc-dlp-s-c0c0/alignment:v0.0.7'
        singularity: '~{singularity_dir}/alignment_v0.0.7.sif'
    }
}


task CoverageMetrics{
    input{
        File bamfile
        File bamfile_bai
        String filename_prefix="output"
        String? singularity_dir
    }
    command<<<
    alignment_utils coverage_metrics --bamfile ~{bamfile} --output ~{filename_prefix}.csv.gz
    >>>
    output{
        File output_csv = "~{filename_prefix}.csv.gz"
        File output_csv_yaml = "~{filename_prefix}.csv.gz.yaml"
    }
    runtime{
        memory: "22 GB"
        cpu: 1
        walltime: "48:00"
        docker: 'us.gcr.io/nygc-dlp-s-c0c0/alignment:v0.0.7'
        singularity: '~{singularity_dir}/alignment_v0.0.7.sif'
    }

}



task AddMetadata{
    input{
        File metrics
        File metrics_yaml
        File metadata_yaml
        String filename_prefix="output"
        String? singularity_dir
    }
    command<<<
    alignment_utils add_metadata --metrics ~{metrics} --metadata ~{metadata_yaml} --output ~{filename_prefix}.csv.gz
    >>>
    output{
        File output_csv = "~{filename_prefix}.csv.gz"
        File output_csv_yaml = "~{filename_prefix}.csv.gz.yaml"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: 'us.gcr.io/nygc-dlp-s-c0c0/alignment:v0.0.7'
        singularity: '~{singularity_dir}/alignment_v0.0.7.sif'
    }
}