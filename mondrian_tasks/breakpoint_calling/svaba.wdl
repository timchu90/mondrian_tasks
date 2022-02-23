version 1.0


task RunSvaba{
    input{
        File normal_bam
        File normal_bai
        File tumour_bam
        File tumour_bai
        File reference
        File reference_fa_fai
        File reference_fa_amb
        File reference_fa_ann
        File reference_fa_bwt
        File reference_fa_pac
        File reference_fa_sa
        String filename_prefix
        String? singularity_image
        String? docker_image
        Int? num_threads = 8
        Int? memory_gb = 12
        Int? walltime_hours = 120
    }
    command{
        svaba run -t ~{tumour_bam} -n ~{normal_bam} -G ~{reference} -z -p ~{num_threads} -a ~{filename_prefix}
    }
    output{
        File output_vcf = "~{filename_prefix}.svaba.somatic.sv.vcf.gz"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: num_threads
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}
