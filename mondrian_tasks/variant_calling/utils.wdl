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
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task MergeBams{
    input{
        Array[File] inputs
        Int? num_threads = 8
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 8
    }
    command<<<
        variant_utils merge_bams \
        --inputs ~{sep=" "inputs} \
        --output merged.bam \
        --tempdir temp \
        --threads ~{num_threads}
        samtools index merged.bam
    >>>
    output{
        File merged_bam = "merged.bam"
        File merged_bai = "merged.bam.bai"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: "~{num_threads}"
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

