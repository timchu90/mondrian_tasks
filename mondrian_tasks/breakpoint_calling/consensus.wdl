version 1.0

task Consensus{
    input{
        File destruct
        File lumpy
        File svaba
        File gridss
        String filename_prefix
        String sample_id
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 24
    }
    command<<<
        mkdir tempdir
        breakpoint_utils consensus \
        --destruct ~{destruct} \
        --lumpy ~{lumpy} --svaba ~{svaba} \
        --gridss ~{gridss} --consensus ~{filename_prefix}_consensus.csv.gz --sample_id ~{sample_id} \
        --tempdir tempdir
    >>>
    output{
        File consensus = "~{filename_prefix}_consensus.csv.gz"
        File consensus_yaml = "~{filename_prefix}_consensus.csv.gz.yaml"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}