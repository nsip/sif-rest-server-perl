package SIFAU::REST::TimeTableCells;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;

our $VERSION = '0.1';
prefix '/TimeTableCells';

get '/' => sub {
	autoGetCollection('TimeTableCells', 'TimeTableCell', q{
			SELECT
					TimeTableCell.RefId, TimeTableCell.TimeTableSubject_RefId,
					TimeTableCell.TeachingGroup_RefId, TimeTableCell.RoomInfo_RefId,
					TimeTableCell.CellType, TimeTableCell.PeriodId, TimeTableCell.DayId,
					TimeTableCell.StaffPersonal_RefId,
					TeachingGroup.SchoolInfo_RefId,
					RoomInfo.RoomNumber,
					StaffPersonal.LocalId as StaffLocalId
			FROM
					TimeTableCell
					LEFT JOIN TeachingGroup ON TimeTableCell.TeachingGroup_RefId = TeachingGroup.RefId
					LEFT JOIN RoomInfo ON TimeTableCell.RoomInfo_RefId = RoomInfo.RefId
					LEFT JOIN StaffPersonal ON TimeTableCell.StaffPersonal_RefId = StaffPersonal.RefId
	});
};

get '/:id' => sub {
	autoGet('TimeTableCell', 'TimeTableCell', q{
                SELECT
                        TimeTableCell.RefId, TimeTableCell.TimeTableSubject_RefId,
                        TimeTableCell.TeachingGroup_RefId, TimeTableCell.RoomInfo_RefId,
                        TimeTableCell.CellType, TimeTableCell.PeriodId, TimeTableCell.DayId,
                        TimeTableCell.StaffPersonal_RefId,
                        TeachingGroup.SchoolInfo_RefId,
                        RoomInfo.RoomNumber,
                        StaffPersonal.LocalId as StaffLocalId
                FROM
                        TimeTableCell
                        LEFT JOIN TeachingGroup ON TimeTableCell.TeachingGroup_RefId = TeachingGroup.RefId
                        LEFT JOIN RoomInfo ON TimeTableCell.RoomInfo_RefId = RoomInfo.RefId
                        LEFT JOIN StaffPersonal ON TimeTableCell.StaffPersonal_RefId = StaffPersonal.RefId
				WHERE
					TimeTableCell.RefId = ?
	});
};

# CREATE Multiple
post '/' => sub {
	die "Not implemented";
};

# CREATE Single
post '/TimeTableCell' => sub {
	autoCreate('TimeTableCell', 'TimeTableCell');
};

# Update set
put '/' => sub {
	die "Not implemented";
};

# Update one
put '/:id' => sub {
	autoUpdate('TimeTableCell', 'TimeTableCell', params->{id});
};

# Delete Set
del '/' => sub {
	die "Not implemented";
};

# Delete Single
del '/:id' => sub {
	autoDelete('TimeTableCell', 'TimeTableCell', params->{id});
};

true;
