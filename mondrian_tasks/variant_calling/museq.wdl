version 1.0


task RunMuseq{
    input{
        File normal_bam
        File normal_bai
        File tumour_bam
        File tumour_bai
        File reference
        File reference_fai
        String interval
        String? singularity_image
        String? docker_image
        Int? num_threads = 1
        Int? memory_gb = 12
        Int? walltime_hours = 96
    }
    command<<<
        mkdir pythonegg
        export PYTHON_EGG_CACHE=$PWD/pythonegg

        mkdir museq_vcf

        intervals=`variant_utils split_interval --interval ~{interval} --num_splits ~{num_threads}`

        echo $intervals

        for interval in $intervals
            do
                echo "museq normal:~{normal_bam} tumour:~{tumour_bam} reference:~{reference} \
                --out museq_vcf/${interval}.vcf --log ${interval}.log -v -i ${interval} ">> commands.txt
            done
        parallel --jobs ~{num_threads} < commands.txt


        variant_utils merge_vcf_files --inputs museq_vcf/*vcf --output merged.vcf
        variant_utils fix_museq_vcf --input merged.vcf --output merged.fixed.vcf
        vcf-sort merged.fixed.vcf > merged.sorted.fixed.vcf
        bgzip merged.sorted.fixed.vcf -c > merged.sorted.fixed.vcf.gz
        bcftools index merged.sorted.fixed.vcf.gz
        tabix -f -p vcf merged.sorted.fixed.vcf.gz
    >>>

    output{
        File vcf = 'merged.sorted.fixed.vcf.gz'
        File vcf_csi = 'merged.sorted.fixed.vcf.gz.csi'
        File vcf_tbi = 'merged.sorted.fixed.vcf.gz.tbi'
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: "~{num_threads}"
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task FixMuseqVcf{
    input{
        File vcf_file
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 8

    }
    command<<<
        variant_utils fix_museq_vcf --input ~{vcf_file} --output output.vcf
        bgzip output.vcf -c > output.vcf.gz
        bcftools index output.vcf.gz
        tabix -f -p vcf output.vcf.gz
    >>>
    output{
        File output_vcf = 'output.vcf.gz'
        File output_csi = 'output.vcf.gz.csi'
        File output_tbi = 'output.vcf.gz.tbi'
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task VariantBam{
    input{
        File bamfile
        File baifile
        Int max_coverage=10000
        Array[String] intervals
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 8
        Int? num_threads = 8
    }
    command<<<
        mkdir variant_bam_outputs
        for interval in ~{sep=" "intervals}
            do
                echo "variant ~{bamfile} -m ~{max_coverage} -k ${interval} -v -b -o variant_bam_outputs/${interval}.bam" >> commands.txt
            done
        parallel --jobs ~{num_threads} < commands.txt

        num_files=`ls variant_bam_outputs/*bam |wc -l`

        echo $num_files

        num_threads_merge=$((~{num_threads} / 2))
        num_threads_merge=$(($num_threads_merge>0 ? $num_threads_merge : 1))

        if [[ $num_files -eq 1 ]]
        then
            mv variant_bam_outputs/*bam merged.bam
        else
            sambamba merge -t $num_threads_merge merged.bam variant_bam_outputs/*bam
        fi
        samtools index merged.bam
    >>>
    output{
        File output_bam = "merged.bam"
        File output_bai = "merged.bam.bai"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: "~{num_threads}"
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}