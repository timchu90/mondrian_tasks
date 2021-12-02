version 1.0

task genotyper{
    input{
        File bam
        File bai
        File vcf_file
        File vcf_file_idx
        Array[String] intervals
        Int num_threads
        String? singularity_dir
        String filename_prefix = "snv_genotyping"
    }
    command<<<
        for interval in ~{sep=" "intervals}
            do
                echo "variant_utils snv_genotyper --interval ${interval} --bam ~{bam} \
                 --targets_vcf ~{vcf_file}  --output ${interval}.genotype.csv.gz" >> commands.txt
            done
        parallel --jobs ~{num_threads} < commands.txt

        inputs=`echo *genotype.csv.gz | sed "s/ / --in_f /g"`
        csverve concat --in_f $inputs  --out_f ~{filename_prefix}.csv.gz --write_header
    >>>
    output{
        File output_csv = "~{filename_prefix}.csv.gz"
        File output_yaml = "~{filename_prefix}.csv.gz.yaml"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "24:00"
        docker: 'us.gcr.io/nygc-dlp-s-c0c0/variant:v0.0.7'
        singularity: '~{singularity_dir}/variant_v0.0.7.sif'
    }
}
