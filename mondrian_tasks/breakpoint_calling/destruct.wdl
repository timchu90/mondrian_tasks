version 1.0



task RunDestruct{
    input{
        File normal_bam
        File tumour_bam
        File reference
        File reference_fai
        File reference_gtf
        File reference_fa_1_ebwt
        File reference_fa_2_ebwt
        File reference_fa_3_ebwt
        File reference_fa_4_ebwt
        File reference_fa_rev_1_ebwt
        File reference_fa_rev_2_ebwt
        File dgv
        File repeats_satellite_regions
        String filename_prefix
        String? singularity_image
        String? docker_image
        Int? num_threads = 8
        Int? memory_gb = 12
        Int? walltime_hours = 120
    }
    command<<<
        echo "genome_fasta = '~{reference}'; genome_fai = '~{reference_fai}'; gtf_filename = '~{reference_gtf}'" > config.py

        destruct run $(dirname ~{reference}) \
        ~{filename_prefix}_breakpoint_table.csv ~{filename_prefix}_breakpoint_library_table.csv \
        ~{filename_prefix}_breakpoint_read_table.csv \
        --bam_files ~{tumour_bam} ~{normal_bam} \
        --lib_ids tumour normal \
        --tmpdir tempdir --pipelinedir pipelinedir --submit local --config config.py --loglevel DEBUG --maxjobs ~{num_threads}
    >>>
    output{
        File breakpoint_table = "~{filename_prefix}_breakpoint_table.csv"
        File library_table = "~{filename_prefix}_breakpoint_library_table.csv"
        File read_table = "~{filename_prefix}_breakpoint_read_table.csv"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: num_threads
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}
