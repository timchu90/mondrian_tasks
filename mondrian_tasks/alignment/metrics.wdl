version 1.0

task CollectMetrics{
    input{
        File wgs_metrics
        File insert_metrics
        File flagstat
        File markdups_metrics
        String cell_id
        String? singularity_dir
        Int column
        String condition
        Int img_col
        String index_i5
        String index_i7
        String index_sequence
        String library_id
        String pick_met
        String primer_i5
        String primer_i7
        Int row
        String sample_id
        String sample_type
        Boolean is_control
    }
    command<<<
        alignment_utils collect_metrics \
        --wgs_metrics ~{wgs_metrics} \
        --insert_metrics ~{insert_metrics} \
        --flagstat ~{flagstat} \
        --markdups_metrics ~{markdups_metrics} \
        --cell_id ~{cell_id} \
        --output output.csv.gz \
        --column ~{column} \
        --condition ~{condition} \
        --img_col ~{img_col} \
        --index_i5 ~{index_i5} \
        --index_i7 ~{index_i7} \
        --index_sequence ~{index_sequence} \
        --library_id ~{library_id} \
        --pick_met ~{pick_met} \
        --primer_i5 ~{primer_i5} \
        --primer_i7 ~{primer_i7} \
        --row ~{row} \
        --sample_id ~{sample_id} \
        --sample_type ~{sample_type} \
        --is_control ~{is_control}
    >>>
    output{
        File output_csv = "output.csv.gz"
        File output_csv_yaml = "output.csv.gz.yaml"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: 'quay.io/mondrianscwgs/alignment:v0.0.5'
        singularity: '~{singularity_dir}/alignment_v0.0.5.sif'
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
        docker: 'quay.io/mondrianscwgs/alignment:v0.0.5'
        singularity: '~{singularity_dir}/alignment_v0.0.5.sif'
    }
}


task AnnotateCoverageMetrics{
    input{
        File metrics
        File metrics_yaml
        File bamfile
        File bamfile_bai
        String filename_prefix="output"
    }
    command<<<
    alignment_utils coverage_metrics --metrics ~{metrics} --bamfile ~{bamfile} --output ~{filename_prefix}.csv.gz
    >>>
    output{
        File output_csv = "~{filename_prefix}.csv.gz"
        File output_csv_yaml = "~{filename_prefix}.csv.gz.yaml"
    }
}