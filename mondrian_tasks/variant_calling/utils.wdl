version 1.0

task VariantMetadata{
    input{
        File final_maf
        File final_vcf
        File final_vcf_csi
        File final_vcf_tbi
        Array[File] sample_vcf
        Array[File] sample_vcf_csi
        Array[File] sample_vcf_tbi
        Array[File] sample_maf
        Array[File] sample_museq_vcf
        Array[File] sample_museq_vcf_csi
        Array[File] sample_museq_vcf_tbi
        Array[File] sample_strelka_snv_vcf
        Array[File] sample_strelka_snv_vcf_csi
        Array[File] sample_strelka_snv_vcf_tbi
        Array[File] sample_strelka_indel_vcf
        Array[File] sample_strelka_indel_vcf_csi
        Array[File] sample_strelka_indel_vcf_tbi
        Array[File] sample_mutect_vcf
        Array[File] sample_mutect_vcf_csi
        Array[File] sample_mutect_vcf_tbi
        Array[File] metadata_yaml_files
        Array[String] samples
String? singularity_image         String? docker_image    }
    command<<<
        variant_utils generate_metadata \
        --maf_file ~{final_maf} \
        --vcf_files ~{final_vcf} ~{final_vcf_csi} ~{final_vcf_tbi} \
        --sample_vcf_files ~{sep=" "sample_vcf} ~{sep=" "sample_vcf_csi} ~{sep=" "sample_vcf_tbi} \
        --sample_maf_files ~{sep=" "sample_maf} \
        --museq_vcf_files ~{sep=" "sample_museq_vcf} ~{sep=" "sample_museq_vcf_csi} ~{sep=" "sample_museq_vcf_tbi} \
        --strelka_snv_files ~{sep=" "sample_strelka_snv_vcf} ~{sep=" "sample_strelka_snv_vcf_csi} ~{sep=" "sample_strelka_snv_vcf_tbi} \
        --strelka_indel_files ~{sep=" "sample_strelka_indel_vcf} ~{sep=" "sample_strelka_indel_vcf_csi} ~{sep=" "sample_strelka_indel_vcf_tbi} \
        --mutect_vcf_files ~{sep=" "sample_mutect_vcf} ~{sep=" "sample_mutect_vcf_csi} ~{sep=" "sample_mutect_vcf_tbi} \
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