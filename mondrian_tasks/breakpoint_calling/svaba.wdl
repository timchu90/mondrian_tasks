version 1.0


task runSvaba{
    input{
        File normal_bam
        File normal_bai
        File tumour_bam
        File tumour_bai
        Int num_threads
        File reference
        File reference_fa_fai
        File reference_fa_amb
        File reference_fa_ann
        File reference_fa_bwt
        File reference_fa_pac
        File reference_fa_sa
String? singularity_image         String? docker_image        String filename_prefix
    }
    command{
        svaba run -t ~{tumour_bam} -n ~{normal_bam} -G ~{reference} -z -p ~{num_threads} -a ~{filename_prefix}
    }
    output{
        File output_vcf = "~{filename_prefix}.svaba.somatic.sv.vcf.gz"
    }
    runtime{
        memory: "8 GB"
        cpu: num_threads
        walltime: "240:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }

}
