# mortality-rates

General-population mortality rates used as the competing-risk rate (`mratevar()`) in
[`stexpectcr`](https://github.com/raoulreulen/my-stata-tools) and in other analyses. One folder per dataset;
build scripts are in `code/`.

Please cite the original source of each dataset and comply with its user agreement when using or redistributing it.

## Datasets

| Folder | File | Source | Coverage |
|---|---|---|---|
| `data/pcsf` | `pcsf_mortrates_hmd_5x1.dta` | [Human Mortality Database](https://www.mortality.org), period death rates 5x1 | PCSF countries (FR, HU, IT, NL, DK, SE, NO, FI, IS, SI, CH, UK), by sex, 5-year age band and year |

## data/pcsf: PCSF countries

`data/pcsf/pcsf_mortrates_hmd_5x1.dta` (Stata 13 format; 69,156 rows)

| Variable | Meaning |
|---|---|
| `ccode` | PCSF country code: 11 France, 21 Hungary, 31 Italy (population-based), 32 Italy (hospital cohort, same rates), 42 Netherlands, 51 Denmark, 52 Sweden, 53 Norway, 54 Finland, 55 Iceland, 61 Slovenia, 71 Switzerland, 81 UK |
| `sex` | 1 male, 2 female |
| `ageband` | lower bound of the 5-year age band, 0, 5, ..., 85 (0 = ages 0-4; 85 = 85-89) |
| `year` | calendar year (HMD period rates; range differs by country) |
| `mortrate` | all-cause mortality rate per person-year |

HMD populations: FRATNP, HUN, ITA, NLD, DNK, SWE, NOR, FIN, ISL, SVN, CHE, GBR_NP.
Years outside a country's HMD range are not filled: clamp to the nearest available year before merging.

```stata
use cohort_split_records, clear      // stset by attained age, stsplit by ageband and year
rename (_age _year) (ageband year)   // match your own variable names
merge m:1 ccode sex ageband year using pcsf_mortrates_hmd_5x1.dta, keep(match master) nogen
stexpectcr Cumexp, ratevar(rate_cancer) mratevar(mortrate) method(2) at(1(1)75)
```

Rebuild from the HMD download with `code/pcsf/build_pcsf_mortrates.do`.

## Adding a dataset

Add `data/<name>/` and `code/<name>/`, then a row in the table above and a short section describing the keys,
rate units and source.
