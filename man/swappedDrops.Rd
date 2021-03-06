\name{swappedDrops}
\alias{swappedDrops}
\alias{removeSwappedDrops}

\title{Clean barcode-swapped droplet data}

\description{Remove the effects of barcode swapping on droplet-based single-cell RNA-seq data, specifically 10X Genomics datasets.}

\usage{
swappedDrops(samples, barcode.length=NULL, ...)

removeSwappedDrops(cells, umis, genes, nreads, ref.genes, min.frac=0.8,
    get.swapped=FALSE, get.diagnostics=FALSE, hdf5.out=TRUE)
}

\arguments{
\item{samples}{A character vector containing paths to the molecule information HDF5 files, produced by CellRanger for 10X Genomics data.
Each file corresponds to one sample in a multiplexed pool.}
\item{barcode.length}{An integer scalar specifying the length of the cell barcode, see \code{\link{read10xMolInfo}}.}
\item{...}{Further arguments to be passed to \code{removeSwappedDrops}.}
\item{cells}{A list of character vectors containing cell barcodes. 
Each vector corresponds to one sample in a multiplexed pool, and each entry of the vector corresponds to one molecule.}
\item{umis}{A list of integer vectors containing encoded UMI sequences, organized as described for \code{cells}.
See \code{?\link{encodeSequences}} to convert sequences to integers.}
\item{genes}{A list of integer vectors specifying the gene indices, organized as described for \code{cells}.
Each index should refer to an element of \code{ref.genes}.}
\item{nreads}{A list of integer vectors containing the number of reads per molecule, organized as described for \code{cells}.}
\item{ref.genes}{A character vector containing the names or symbols of all genes.}
\item{min.frac}{A numeric scalar specifying the minimum fraction of reads required for a swapped molecule to be assigned to a sample.}
\item{get.swapped}{A logical scalar indicating whether the UMI counts corresponding to swapped molecules should also be returned.}
\item{get.diagnostics}{A logical scalar indicating whether to return the number of reads for each swapped molecule in each sample.}
\item{hdf5.out}{A logical scalar indicating whether the diagnotic matrix should be returned as a \linkS4class{HDF5Matrix}.}
}

\details{
Barcode swapping on the Illumina sequencer occurs when multiplexed samples undergo PCR re-amplification on the flow cell by excess primer with different barcodes.
This results in sequencing of the wrong sample barcode and molecules being assigned to incorrect samples after debarcoding.
With droplet data, there is the opportunity to remove such effects based on the combination of gene, UMI and cell barcode for each observed transcript molecule.
It is very unlikely that the same combination will arise from different molecules in multiple samples.
Thus, observation of the same combination across multiple samples is indicative of barcode swapping.

We can remove swapped molecules based on the number of reads assigned to each gene-UMI-barcode combination.
From the total number of reads assigned to that combination, the fraction of reads in each sample is calculated.
The sample with the largest fraction that is greater than \code{min.frac} is defined as the putative sample of origin to which the molecule is assigned.
This assumes that the swapping rate is low, so the sample of origin for a molecule should contain the majority of the reads.
In other all samples, reads for the combination are assumed to derive from swapping and do not contribute to the count matrix.
Setting \code{min.frac=1} will effectively remove all molecules that appear in multiple samples.
We do not recommend setting \code{min.frac} lower than 0.5.

If \code{diagnostics=TRUE}, a diagnostics matrix is returned containing the number of reads per gene-UMI-barcode combination in each sample.
Each row corresponds to a combination and each column corresponds to a sample.
This can be useful for examining the level of swapping across samples on a molecule-by-molecule basis, 
though for the sake of memory, the actual identity of the molecules is not returned.
By default, the matrix is returned as a \linkS4class{HDF5Matrix}, which reduces memory usage and avoids potential issues with integer overflow.
If \code{hdf5.out=FALSE}, a sparse matrix is returned instead, which is faster but uses more memory.

\code{swappedDrops} is a wrapper around \code{removeSwappedDrops} that extracts the relevant data from the 10X Genomics molecule information file.
For other types of droplet-based data, it may be more convenient to call \code{removeSwappedDrops} directly.
} 

\value{
A list is returned with the \code{cleaned} entry, itself a list of sparse matrices is returned.
Each matrix corresponds to a sample and contains the UMI count for each gene (row) and cell barcode (column) after removing swapped molecules.
All cell barcodes that were originally observed are reported as columns, though note that it is possible for some barcodes to contain no counts.

If \code{get.swapped=TRUE}, a \code{swapped} entry is returned in the top-level list.
This is a list containing sample-specific sparse matrices of UMI counts corresponding to the swapped molecules.
Adding the cleaned and swapped matrices for each sample should yield the total UMI count prior to removal of swapped molecules. 

If \code{get.diagnostics=TRUE}, the top-level list will also contain an additional \code{diagnostics} matrix.
}

\section{Format of the molecule information file}{
\code{swappedDrops} makes a few assumptions about the nature of the data in each molecule information file.
These are necessary to simplify downstream processing and are generally acceptable in most cases.

Each molecule information file should contain data from only a single 10X run.
Users should \emph{not} combine multiple samples into a single molecule information file.
The function will emit a warning upon detecting multiple GEM groups from any molecule information file.
Molecules with different GEMs will not be recognised as coming from a different sample, though they will be recognised as being derived from different cell-level libraries.

In files produced by CellRanger version 3.0, an additional per-molecule field is present indicating the (c)DNA library from which the molecule was derived.
Library preparation can be performed separately for different features (e.g., antibodies, CRISPR tags) such that one 10X run can contain data from multiple libraries.
This allows for arbitrarily complicated multiplexing schemes - for example, gene expression libraries might be multiplexed together across one set of samples,
while the antibody-derived libraries might be multiplexed across another \emph{different} set of samples.
For simplicity, we assume that multiplexing was performed across the same set of \code{samples} for all libraries therein.
}

\author{
Jonathan Griffiths,
with modifications by Aaron Lun
}

\seealso{
\code{\link{read10xMolInfo}},
\code{\link{encodeSequences}}
}

\examples{
# Mocking up some 10x HDF5-formatted data, with swapping.
curfiles <- DropletUtils:::sim10xMolInfo(tempfile(), nsamples=3)

# Obtaining count matrices with swapping removed.
out <- swappedDrops(curfiles)
lapply(out$cleaned, dim)

out <- swappedDrops(curfiles, get.swapped=TRUE, get.diagnostics=TRUE)
names(out)
}

\references{
Griffiths JA, Lun ATL, Richard AC, Bach K, Marioni JC (2018).
Detection and removal of barcode swapping in single-cell RNA-seq data.
\emph{Nat. Commun.} 9, 1:2667.
}
