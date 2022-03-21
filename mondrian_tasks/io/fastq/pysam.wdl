version 1.0

task GenerateIntervals{
    input{
        File reference
        Array[String] chromosomes
        Int interval_size = 1000000
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 48
    }
    command<<<
        variant_utils generate_intervals --reference ~{reference} --chromosomes ~{sep=" "  chromosomes} --size ~{interval_size} > intervals.txt
    >>>
    output{
        Array[String] intervals = read_lines('intervals.txt')
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}
