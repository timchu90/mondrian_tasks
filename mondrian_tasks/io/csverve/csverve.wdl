version 1.0


task RewriteCsv{
    input{
        File infile
        String dtypes
        String? singularity_image
        String? docker_image
        Int? memory_gb = 8
        Int? walltime_hours = 8
    }
    command<<<
        csverve_utils rewrite_csv --infile ~{infile} --outfile outfile.csv.gz --dtypes ~{dtypes}
    >>>
    output{
        File outfile = 'outfile.csv.gz'
        File outfile_yaml = 'outfile.csv.gz.yaml'
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task ConcatenateCsv {
    input {
        Array[File] inputfile
        Array[File] inputyaml
        String filename_prefix = 'output'
        String? singularity_image
        String? docker_image
        Int? memory_gb = 8
        Int? walltime_hours = 8
    }
    command {
        csverve concat --in_f ~{sep=" --in_f " inputfile} --out_f ~{filename_prefix}.csv.gz --write_header

    }
    output {
        File outfile = "~{filename_prefix}.csv.gz"
        File outfile_yaml = "~{filename_prefix}.csv.gz.yaml"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: '~{walltime_hours}:00'
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task MergeCsv{
    input{
        Array[File] inputfiles
        Array[File] inputyamls
        String on
        String how
        String? singularity_image
        String? docker_image
        Int? memory_gb = 8
        Int? walltime_hours = 8
    }
    command<<<
        csverve merge --in_f ~{sep=" --in_f " inputfiles} --out_f merged.csv.gz --on ~{on} --how ~{how} --write_header
    >>>
    output{
        File outfile = "merged.csv.gz"
        File outfile_yaml = 'merged.csv.gz.yaml'
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: '~{walltime_hours}:00'
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}



task FinalizeCsv {
    input {
        Array[File] inputfile
        String? singularity_image
        String? docker_image
        Int? memory_gb = 8
        Int? walltime_hours = 8
    }
    command {
        variant_utils concat_csv  --inputs ~{sep=" " inputfile} --output concat.csv --write_header

    }
    output {
        File outfile = "concat.csv"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}
