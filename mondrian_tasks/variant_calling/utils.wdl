version 1.0

task VariantMetadata{
    input{
        Map[String, Array[File]] files
        Array[File] metadata_yaml_files
        Array[String] samples
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 8
    }
    command<<<
        variant_utils generate_metadata \
        --files ~{write_json(files)} \
        --metadata_yaml_files ~{sep=" "metadata_yaml_files} \
        --samples ~{sep=" "samples} \
        --metadata_output metadata.yaml
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