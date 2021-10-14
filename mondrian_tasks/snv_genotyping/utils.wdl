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
    }
    command<<<
        for interval in ~{sep=" "intervals}
            do
                echo "variant_utils snv_genotyper --interval ${interval} --bam ~{bam} \
                 --targets_vcf ~{vcf_file}  --output ${interval}.genotype.csv.gz" >> commands.txt
            done
        parallel --jobs ~{num_threads} < commands.txt

        inputs=`echo *genotype.csv.gz | sed "s/ / --in_f /g"`
        csverve concat --in_f $inputs  --out_f merged.csv.gz --write_header
    >>>
    output{
        File output_csv = "merged.csv.gz"
        File output_yaml = "merged.csv.gz.yaml"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "24:00"
        docker: 'quay.io/mondrianscwgs/variant:v0.0.4'
        singularity: '~{singularity_dir}/variant_v0.0.4.sif'
    }
}
