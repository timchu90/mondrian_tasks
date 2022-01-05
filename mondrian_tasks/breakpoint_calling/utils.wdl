version 1.0

task BreakpointMetadata{
    input{
        File consensus
        File consensus_yaml
        Array[File] destruct_files
        Array[File] destruct_reads_files
        Array[File] destruct_library_files
        Array[File] lumpy_vcf_files
        Array[File] gridss_vcf_files
        Array[File] svaba_vcf_files
        Array[File] metadata_yaml_files
        Array[String] samples
        String? singularity_dir
    }
    command<<<
        breakpoint_utils generate_metadata \
        --consensus_files ~{consensus} ~{consensus_yaml} \
        --destruct_files ~{sep=" "destruct_files} \
        --destruct_reads_files ~{sep=" "destruct_reads_files} \
        --destruct_library_files ~{sep=" "destruct_library_files} \
        --lumpy_vcf_files ~{sep=" "lumpy_vcf_files} \
        --gridss_vcf_files ~{sep=" "gridss_vcf_files} \
        --svaba_vcf_files ~{sep=" "svaba_vcf_files} \
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
        docker: 'quay.io/mondrianscwgs/breakpoint:v0.0.9'
        singularity: '~{singularity_dir}/breakpoint_v0.0.9.sif'
    }
}