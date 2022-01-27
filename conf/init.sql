USE mydb;

create table my_tbl
(
    my_id           INT          NOT NULL AUTO_INCREMENT,
    my_field        VARCHAR(100) NOT NULL,
    submission_date DATE,
    time_created    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (my_id)
);